#!/bin/bash
# mimestream-restore.sh — restore a Mimestream configuration archive produced by
# mimestream-backup.sh onto a new Mac.
#
# Usage:  ./mimestream-restore.sh /path/to/mimestream-config-YYYYMMDD-HHMMSS.tgz
#
# Prerequisites on the NEW Mac:
#   * Mimestream.app installed in /Applications (same version as the backup).
#   * The terminal app running this script has Full Disk Access.
#   * Do NOT add any accounts to Mimestream before running this.
set -euo pipefail

ARCHIVE="${1:-}"
[[ -n "$ARCHIVE" && -f "$ARCHIVE" ]] || { echo "Usage: $0 <backup.tgz>" >&2; exit 1; }

APP="/Applications/Mimestream.app"
CONTAINER_ROOT="$HOME/Library/Containers/com.mimestream.Mimestream"
CONTAINER="$CONTAINER_ROOT/Data/Library"
GROUP="$HOME/Library/Group Containers/group.com.mimestream.Mimestream"

say()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
die()  { printf '\033[1;31mERROR:\033[0m %s\n' "$*" >&2; exit 1; }

quit_mimestream() {
  if pgrep -xq Mimestream; then
    say "Quitting Mimestream…"
    osascript -e 'tell application "Mimestream" to quit' >/dev/null 2>&1 || true
    for _ in $(seq 1 30); do
      pgrep -xq Mimestream || break
      sleep 1
    done
    pgrep -xq Mimestream && die "Mimestream is still running; quit it manually and re-run."
  fi
  return 0
}

# --- sanity checks ----------------------------------------------------------
[[ -d "$APP" ]] || die "Mimestream.app not found in /Applications — install it first."

STAGE="$(mktemp -d)"
trap 'rm -rf "$STAGE"' EXIT
say "Extracting archive…"
tar -C "$STAGE" -xzf "$ARCHIVE"
[[ -f "$STAGE/Library/Application Support/Mimestream/Persistence.plist" ]] \
  || die "Archive does not contain Persistence.plist — is this a mimestream-backup.sh archive?"

# Version check (warn only; a newer app can usually migrate older data,
# an OLDER app cannot read newer data).
if [[ -f "$STAGE/MANIFEST.txt" ]]; then
  SRC_VER="$(grep '^mimestream_version=' "$STAGE/MANIFEST.txt" | cut -d= -f2)"
  SRC_BLD="$(grep '^mimestream_build='   "$STAGE/MANIFEST.txt" | cut -d= -f2)"
  DST_VER="$(defaults read "$APP/Contents/Info" CFBundleShortVersionString 2>/dev/null || echo unknown)"
  DST_BLD="$(defaults read "$APP/Contents/Info" CFBundleVersion 2>/dev/null || echo unknown)"
  echo "  backup from Mimestream $SRC_VER ($SRC_BLD); installed here: $DST_VER ($DST_BLD)"
  if [[ "$SRC_BLD" != "$DST_BLD" ]]; then
    if [[ "$DST_BLD" =~ ^[0-9]+$ && "$SRC_BLD" =~ ^[0-9]+$ && "$DST_BLD" -lt "$SRC_BLD" ]]; then
      die "Installed Mimestream is OLDER than the backup. Update Mimestream first."
    fi
    echo "  WARNING: versions differ. Mimestream will migrate the data on first launch."
    read -r -p "  Continue anyway? [y/N] " ans
    [[ "$ans" =~ ^[Yy]$ ]] || exit 1
  fi
fi

# --- step 1: make sure the sandbox container exists ---------------------------
# Launching the app once lets macOS create the container with the right
# sandbox metadata; we then quit it before touching anything.
if [[ ! -d "$CONTAINER/Application Support" ]]; then
  say "Container not present — launching Mimestream once to create it…"
  open -a Mimestream
  for _ in $(seq 1 60); do
    [[ -d "$CONTAINER/Application Support" ]] && break
    sleep 1
  done
  sleep 3   # let it finish first-launch writes
  [[ -d "$CONTAINER/Application Support" ]] || die "Container was not created at $CONTAINER"
fi
quit_mimestream

# Full Disk Access check
if ! ls "$CONTAINER/Application Support" >/dev/null 2>&1; then
  die "Cannot read $CONTAINER. Grant Full Disk Access to your terminal app, restart it, and re-run."
fi

# --- step 2: remove the fresh (empty) config the first launch created --------
say "Removing freshly-created config so it can't shadow the restore…"
AS="$CONTAINER/Application Support/Mimestream"
mkdir -p "$AS" "$CONTAINER/Preferences"
rm -f "$AS/Persistence.plist" "$AS/License.mimestream-license"
rm -f "$AS"/Mimestream.sqlite "$AS"/Mimestream.sqlite-wal "$AS"/Mimestream.sqlite-shm
rm -f "$CONTAINER/Preferences/com.mimestream.Mimestream.plist"

# --- step 3: copy the backup into place --------------------------------------
say "Restoring configuration files…"
cp -p "$STAGE/Library/Application Support/Mimestream/"* "$AS/"
[[ -f "$STAGE/Library/Preferences/com.mimestream.Mimestream.plist" ]] \
  && cp -p "$STAGE/Library/Preferences/com.mimestream.Mimestream.plist" "$CONTAINER/Preferences/"

if [[ -d "$STAGE/GroupContainer" ]]; then
  mkdir -p "$GROUP"
  rsync -a "$STAGE/GroupContainer/" "$GROUP/" 2>/dev/null \
    && echo "  + group container restored" \
    || echo "  ! could not write group container (skipped; not critical)"
fi

# Make sure the files are owned by the current user (in case the archive
# was created under a different account name on the old Mac).
chown -R "$USER" "$AS" "$CONTAINER/Preferences/com.mimestream.Mimestream.plist" 2>/dev/null || true

# --- step 4: flush the preferences daemon ------------------------------------
# cfprefsd caches plists in memory; without this it can overwrite the restored
# Preferences plist with the empty one it saw at first launch.
say "Flushing cfprefsd cache…"
killall cfprefsd 2>/dev/null || true
sleep 2

# --- step 5: verify & launch -------------------------------------------------
ACCOUNTS="$(plutil -extract accounts raw -o - "$AS/Persistence.plist" 2>/dev/null || echo '?')"
PROFILES="$(plutil -extract profiles raw -o - "$AS/Persistence.plist" 2>/dev/null || echo '?')"
say "Restored: $ACCOUNTS accounts, $PROFILES profiles."

say "Launching Mimestream…"
open -a Mimestream
cat <<'EOF'

Next steps:
  * Accounts and profiles should all be present. Each account will show a
    sign-in prompt — re-authorize with Google (OAuth tokens live in the
    Keychain and are not part of the backup).
  * The message cache was not restored; Mimestream will resync from Gmail.
EOF
