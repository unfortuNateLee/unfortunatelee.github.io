---
title: unfortuNateLee's Stuff
layout: default
---

<style>
  .nl-hero { display: flex; gap: 28px; align-items: center; flex-wrap: wrap; margin: 8px 0 32px; }
  .nl-hero img { width: 140px; height: 140px; border-radius: 50%; object-fit: cover; box-shadow: 0 4px 16px rgba(0,0,0,.18); flex: none; }
  .nl-hero h1 { margin: 0 0 6px; font-size: 2rem; line-height: 1.15; border: none; padding: 0; }
  .nl-hero h1 span { color: #d73a49; }
  .nl-hero p { margin: 0 0 6px; max-width: 60ch; }
  .nl-tag { color: #6a737d; font-size: .95rem; }
  .nl-cta { display: inline-block; margin: 14px 10px 0 0; padding: 8px 16px; border-radius: 6px; text-decoration: none !important; font-weight: 600; font-size: .95rem; }
  .nl-cta.primary { background: #0366d6; color: #fff; }
  .nl-cta.secondary { border: 1px solid #d1d5da; color: #24292e; }
  .nl-cta:hover { opacity: .88; }
  .nl-section h2 { margin-top: 40px; }
  .nl-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(230px, 1fr)); gap: 14px; margin: 16px 0 8px; }
  .nl-card { display: block; border: 1px solid #e1e4e8; border-radius: 8px; padding: 16px; text-decoration: none !important; color: inherit; transition: transform .12s, box-shadow .12s; background: #fff; }
  .nl-card:hover { transform: translateY(-2px); box-shadow: 0 6px 18px rgba(0,0,0,.10); border-color: #c8ccd1; }
  .nl-card .ico { font-size: 1.6rem; line-height: 1; margin-bottom: 8px; }
  .nl-card strong { display: block; color: #0366d6; margin-bottom: 4px; }
  .nl-card small { color: #586069; line-height: 1.4; display: block; }
  .nl-note { color: #6a737d; font-size: .9rem; margin-top: 10px; }
  .nl-foot { margin-top: 48px; padding-top: 16px; border-top: 1px solid #e1e4e8; color: #6a737d; font-size: .9rem; }
  @media (max-width: 560px) { .nl-hero { flex-direction: column; align-items: flex-start; } }
</style>

<div class="nl-hero">
  <img src="Nate_Lee.jpeg" alt="Nate Lee">
  <div>
    <h1>Hi, I'm <span>unfortu</span>Nate Lee.</h1>
    <p class="nl-tag">Principal cybersecurity engineer · Hampton Roads, VA · CISSP</p>
    <p>I spend my days figuring out how likely things are to go wrong with federal systems, and I spend some of my evenings vibe-coding small browser tools with Claude so I don't have to install anything. This site is where both of those end up.</p>
    <a class="nl-cta primary" href="resume">Read my résumé</a>
    <a class="nl-cta secondary" href="/tools/">Browse the tools</a>
  </div>
</div>

<div class="nl-section" markdown="1">

## Who is this guy?

Former fetus with over four decades of experience converting oxygen to carbon dioxide (except for those 53 minutes in 2023...).

Follower of Jesus Christ. Trying to be a good person and to make this good world an even better place by loving God and loving others. Trying to be a love-your-neighbor Christian, not a culture-war kind.

Husband to one wife (that we know of), father to one son.

Passionate about technology. Player of story-driven video games. Listener of audiobooks. Enjoyer of quality sci-fi and fantasy. Purveyor of dadjokes. Dabbler in 3D printing. Player of board games. Amateur carpenter.

Volunteer with [The Norfolk Street Choir](https://thenorfolkstreetchoir.org) and [Neighborhood](https://thisisneighborhood.com).

Twenty-five-plus years in cybersecurity compliance and risk assessment. Architect of MITRE's [Adaptive Cybersecurity Testing (ACT)](https://act.mitre.org) risk-based assessment framework.

Before that: Common Criteria and FIPS 140 certifications, security controls assessments, and a lot of policy writing. The full story, with all the jargon, is on the [résumé](resume).

## Experiments in vibe coding

Tools I've vibe coded (i.e., through iterative prompting) using Claude and Codex. Everything runs entirely in your browser. Nothing you drop in is uploaded anywhere.

</div>

<div class="nl-grid">
  <a class="nl-card" href="tools/bitmap_to_SVG_converter.html">
    <div class="ico">🖼️</div>
    <strong>Bitmap → SVG</strong>
    <small>Trace a PNG or JPEG into a clean, scalable vector. This works <i>OK</i>.</small>
  </a>
  <a class="nl-card" href="tools/SVG-to-STL_converter.html">
    <div class="ico">🧊</div>
    <strong>SVG → STL</strong>
    <small>Extrude a 2-D vector into a printable 3-D mesh. Not great.</small>
  </a>
  <a class="nl-card" href="tools/STL_to_USDZ_converter.html">
    <div class="ico">📱</div>
    <strong>STL → USDZ</strong>
    <small>Convert a 3-D print file into Apple's AR Quick Look format. Not great.</small>
  </a>
  <a class="nl-card" href="tools/SVG_to_USDZ_converter.html">
    <div class="ico">✨</div>
    <strong>SVG → USDZ</strong>
    <small>Go straight from a vector to an AR-ready object in one step. I love your optimism!</small>
  </a>
  <a class="nl-card" href="tools/contacts-graph/index.html">
    <div class="ico">🕸️</div>
    <strong>Contact Relationship Map</strong>
    <small>Drop in a .vcf export, see and edit who's related to whom, export it back. This is getting <i>pretty good<i>.</small>
  </a>
  <a class="nl-card" href="tools/sorting-visualizer.html">
    <div class="ico">📊</div>
    <strong>Sorting Visualizer</strong>
    <small>Watch the classic sorting algorithms race each other. Fun, could be better.</small>
  </a>
</div>

<p class="nl-note">Not a web page, but also here: <a href="tools/mimestream-backup/mimestream-backup.sh">mimestream-backup.sh</a> and <a href="tools/mimestream-backup/mimestream-restore.sh">mimestream-restore.sh</a>, shell scripts that back up and restore a Mimestream configuration without the resyncable message cache. Useful for moving a Mimestream config to a new Mac.</p>

<div class="nl-foot">
  Built with GitHub Pages, a little Markdown, and a lot of Claude. Reach me at nathan (over-yonder-at) teamlee.fun.
</div>
