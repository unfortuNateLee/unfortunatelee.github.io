#!/bin/bash
# mimestream-backup.sh — back up Mimestream's configuration (accounts, profiles,
# settings, license) WITHOUT the resyncable message cache.
#
# Usage:  ./mimestream-backup.sh [destination-dir]
#         (default destination: ~/Desktop)
#
# Requires: the terminal app running this script needs Full Disk Access
# (System Settings → Privacy & Security → Full Disk Access) because macOS
# protects other apps' sandbox containers.
set -euo pipefail

DEST_DIR="${1:-$HOME/Desktop}"
APP="/Applications/Mimestream.app"
CONTAINER="$HOME/Library/Containers/com.mimestream.Mimestream/Data/Library"
GROUP="$HOME/Library/Group Containers/group.com.mimestream.Mimestream"
STAMP="$(date +%Y%m%d-%H%M%S)"
ARCHIVE="$DEST_DIR/mimestream-config-$STAMP.tgz"

say()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
die()  { printf '\033[1;31mERROR:\033[0m %s\n' "$*" >&2; exit 1; }

# --- sanity checks ----------------------------------------------------------
[[ -d "$APP" ]] || die "Mimestream.app not found in /Applications"
[[ -d "$CONTAINER" ]] || die "Container not found: $CONTAINER"
mkdir -p "$DEST_DIR"

# Full Disk Access check: try to list the container's Application Support dir.
if ! ls "$CONTAINER/Application Support/Mimestream" >/dev/null 2>&1; then
  die "Cannot read $CONTAINER/Application Support/Mimestream.
Grant Full Disk Access to your terminal app, restart it, and re-run."
fi

# --- quit Mimestream cleanly --------------------------------------------------
if pgrep -xq Mimestream; then
  say "Quitting Mimestream…"
  osascript -e 'tell application "Mimestream" to quit' >/dev/null 2>&1 || true
  for _ in $(seq 1 30); do
    pgrep -xq Mimestream || break
    sleep 1
  done
  pgrep -xq Mimestream && die "Mimestream is still running; quit it manually and re-run."
fi

# --- record version info so the restore script can sanity-check --------------
VERSION="$(defaults read "$APP/Contents/Info" CFBundleShortVersionString 2>/dev/null || echo unknown)"
BUILD="$(defaults read "$APP/Contents/Info" CFBundleVersion 2>/dev/null || echo unknown)"
STAGE="$(mktemp -d)"
trap 'rm -rf "$STAGE"' EXIT

cat > "$STAGE/MANIFEST.txt" <<EOF
mimestream_version=$VERSION
mimestream_build=$BUILD
source_host=$(scutil --get ComputerName 2>/dev/null || hostname)
source_user=$USER
created=$(date -Iseconds)
EOF

# --- collect files -----------------------------------------------------------
# Layout inside the archive mirrors the paths relative to the container's
# Data/Library, plus an optional group-container directory and the manifest.
say "Collecting configuration files…"
mkdir -p "$STAGE/Library/Application Support/Mimestream" "$STAGE/Library/Preferences"

AS="$CONTAINER/Application Support/Mimestream"
for f in Persistence.plist License.mimestream-license; do
  if [[ -f "$AS/$f" ]]; then
    cp -p "$AS/$f" "$STAGE/Library/Application Support/Mimestream/"
    echo "  + Application Support/Mimestream/$f"
  else
    echo "  ! missing (skipped): Application Support/Mimestream/$f"
  fi
done

PREFS="$CONTAINER/Preferences/com.mimestream.Mimestream.plist"
if [[ -f "$PREFS" ]]; then
  # Flush cfprefsd so the on-disk plist is current before copying.
  killall cfprefsd 2>/dev/null || true
  sleep 1
  cp -p "$PREFS" "$STAGE/Library/Preferences/"
  echo "  + Preferences/com.mimestream.Mimestream.plist"
else
  echo "  ! missing (skipped): Preferences/com.mimestream.Mimestream.plist"
fi

if [[ -d "$GROUP" ]] && ls "$GROUP" >/dev/null 2>&1; then
  mkdir -p "$STAGE/GroupContainer"
  # Exclude caches inside the group container too.
  rsync -a --exclude 'Library/Caches' "$GROUP/" "$STAGE/GroupContainer/" 2>/dev/null \
    && echo "  + Group Containers/group.com.mimestream.Mimestream (minus caches)" \
    || echo "  ! group container unreadable (skipped)"
fi

# Deliberately NOT included (resyncable / disposable):
#   Application Support/Mimestream/Mimestream.sqlite{,-wal,-shm}  (message cache, ~1.3 GB)
#   Application Support/Mimestream/Attachments/
#   Caches/, HTTPStorages/, WebKit/, Mail Downloads/, Logs/

# --- archive -----------------------------------------------------------------
say "Writing $ARCHIVE"
tar -C "$STAGE" -czf "$ARCHIVE" .
say "Verifying archive…"
tar -tzf "$ARCHIVE" | sed 's/^/  /'

[[ -f "$STAGE/Library/Application Support/Mimestream/Persistence.plist" ]] \
  || echo "WARNING: Persistence.plist was not captured — accounts/profiles will NOT restore."

ACCOUNTS="$(plutil -extract accounts raw -o - "$STAGE/Library/Application Support/Mimestream/Persistence.plist" 2>/dev/null || echo '?')"
PROFILES="$(plutil -extract profiles raw -o - "$STAGE/Library/Application Support/Mimestream/Persistence.plist" 2>/dev/null || echo '?')"

say "Done. Mimestream $VERSION ($BUILD): $ACCOUNTS accounts, $PROFILES profiles captured."
echo "Archive: $ARCHIVE"
echo "Note: Google OAuth tokens live in the login Keychain and are not in this archive;"
echo "      you will re-authorize each account after restoring."
