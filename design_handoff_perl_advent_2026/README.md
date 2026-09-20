# Handoff: Perl Advent Calendar — 2026 re-skin

## Overview
A festive 2026 theme for the **Perl Advent Calendar** (`perladvent.org/2026/`), generated
by [`WWW::AdventCalendar`](https://github.com/perladvent/WWW-AdventCalendar). It re-skins the
two page templates the generator produces — the **month index** (styled as advent doors) and
the **per-day article page** — plus optional JavaScript, Open-Graph image handling, and a
fallback share card.

## About the design files — READ FIRST
Unlike a typical design handoff, most of this bundle is **production-ready, drop-in code**, not
just a reference mockup, because the target "codebase" is a CSS-driven static-site generator:

| File | What it is | Where it goes in the repo |
| --- | --- | --- |
| `perl-advent-2026.css` | **Drop-in stylesheet.** Full replacement for the generator's stylesheet. | Replace `share/templates/style.css` (see note ↓) — or serve as the year's extra CSS via `css_hrefs`. |
| `advent.js` | **Optional progressive enhancement** — dark-mode toggle, localStorage "visited" ticks, optical number centering. | Ship next to `style.css`; add one `<script>` line to `share/templates/page.mhtml`. |
| `integration-og-images.md` | Exact Perl/Mason snippets for first-image `og:image` + feature banner. | Edits `lib/WWW/AdventCalendar/Article.pm` and `share/templates/page.mhtml` / `article.mhtml`. |
| `og-default.png` | 1200×630 fallback share card (night-sky wordmark). | Ship into each year's output dir alongside `style.css`. |
| `og-card.html` | Light-DOM source used to regenerate `og-default.png` if copy changes. | Not deployed — tooling only. |
| `Perl Advent 2026 - Production.dc.html` | **Design reference / live preview** of the real generator markup styled by the CSS. | Not deployed — visual spec only. |

> **Stylesheet note:** the generator's `share/templates/style.css` is an HTML::Mason template
> full of `<% $color{...} %>` interpolations fed by `Color::Palette`. `perl-advent-2026.css` is
> **plain static CSS** with a fixed brand palette (CSS custom properties, not Mason). Simplest
> path: replace `style.css` with this file and drop the `%color` plumbing for 2026. Alternatively
> keep `style.css` minimal and add this via `css_hrefs` — it is self-contained and overrides cleanly.

## Fidelity
**High-fidelity, production code.** Final colors, typography, spacing, and interactions. The CSS
targets the generator's real class names verbatim (confirmed against
`perladvent/WWW-AdventCalendar@main`), so no re-implementation is needed — install and go.

## The two screens

### 1. Index — the calendar (advent doors)
Real markup: `<table class="calendar">`, 7 columns Sun–Sat, cells
`<td id="dec-01" class="day advent"><a class="article" href="2026-12-01.html">1</a></td>`.
- **Doors** (`td.day.advent a.article`): rounded gift-wrap cells (150° gradient) with a ribbon
  cross drawn as background layers, and a cream **"ribbon-ball" sticker** (`::before`, z-index −1 —
  above the wrap, below the number) carrying the date. Hover lifts −2px + shadow.
- **Wrap colour rotates by DATE mod 4** (1 red, 2 green, 3 navy, 4 gold, repeat) via `:is(#dec-NN…)`
  selectors — a diagonal pattern that shifts each week and never groups by weekday.
- **Today** (`.today`): gold radial door, 3px gold ring, warm glow.
- **Future** (`.future`, ships with no `<a>` — server-side date lock): muted recessed cell with a
  🔒 padlock glyph. No JS needed for locking; the generator rebuilds daily.
- **Missing** (`.missing`): the door was opened but no article — recessed dashed "empty" panel
  (NOT a black void). Replaces the generator's coal-black default.
- **Dec 25** (`#dec-25`): Christmas gold special.
- Header (`#header`) + tagline (`#tagline`) are **full-bleed** night-sky bands (100vw) with a
  candy-stripe edge and twinkling string-light dots.
- Responsive < 620px: the 7-col table collapses to a single stacked column (the "nice list").

### 2. Article — the day page
Real markup: `#content` → `h1.title`, `.subtitle` (topic − date), `.pod` body, `#author`, `ul#pager`.
- Body `.pod`: 66ch measure, 1.06em/1.72 reading type; inline `code` on green chips; `blockquote`
  with green left rule on a warm callout.
- **Code listings** (`table.code-listing` with `.line-numbers` + `.code`): dark card, tuned syntax
  palette for BOTH the PPI classes (`.keyword/.string/.comment/…`) and the Vim classes
  (`.synStatement/.synConstant/.synComment/…`) — the generator uses Vim (`Pod::Elemental::Transformer::VimHTML`).
- **Pager** (`#pager .previous/.next`): pill buttons with ← / → affordances; fixed the earlier
  flush-border overlap (real min-height so the year-line rule clears the buttons).
- `.feature-image`: full-bleed banner (≤420px, `object-fit: cover`) shown when a post has an image.

## Interactions & behavior
- **Door open/lock:** date-gated server-side; future days have no link. No JS.
- **Dark mode:** `@media (prefers-color-scheme: dark)` auto + `<html data-theme="light|dark">`
  manual override. `advent.js` injects the toggle (auto → light → dark), remembered in localStorage.
- **Visited ticks:** `advent.js` marks doors whose article you've opened (localStorage), gold ✓ badge.
- **Optical number centering:** `advent.js` measures each Bebas Neue digit's ink and nudges it so the
  glyph is visually centered on the sticker (CSS only centers the advance box). Lone "1" gets an extra
  −0.05em to weight its stem over its thin left flag.
- Motion 120–280ms; all transitions disabled under `prefers-reduced-motion`.

## Design tokens (CSS custom properties, top of `perl-advent-2026.css`)
- **Brand:** red `#c0362c`, green `#1a6b3c`, gold `#f2b441`, amber `#e0962a`.
- **Light:** paper `#fbf7ef`, surface `#fff`, ink `#2b3546`, heading `#16304d`, muted `#5b6a7d`,
  link `#1a5fb4`, border `#e8dfce`.
- **Night (header):** `#0b1826 → #132a44`, sub-text `#9fc0dd`.
- **Code:** bg `#0f2236`, ink `#e8eef6`; syntax greens `#7fd39b`, strings `#f2a29c`, numbers/gold
  `#f2b441`, comments `#7d92ab`, identifiers `#9ec5ff`, preproc/violet `#c9b8ff`.
- **Dark theme** re-maps the same variable names (see `[data-theme="dark"]` + the media query).
- Radii 12–14px; shadow `0 8px 22px -12px rgba(11,24,38,.45)`; motion ease `cubic-bezier(.2,0,.2,1)`.

## Typography (self-host — TODO on your side)
`@font-face` at the top of the CSS points to `./fonts/`:
- `SourceSans3.woff2` (variable 300–900) + `SourceSans3-Italic.woff2` — UI/body.
- `SourceCodePro.woff2` (variable 400–600) — code + meta.
- `BebasNeue-Regular.woff2` — the big day numbers + wordmark.

Download these from Google Fonts and place in `fonts/`, **or** swap the `@font-face` block for the
one-line Google Fonts `@import` documented at the bottom of the CSS. Fonts were intentionally left
un-vendored per the client (to be added at implementation time).

## Assets
- `og-default.png` — 1200×630 fallback OG card, built in-project (night-sky wordmark, door motif).
  Regenerate from `og-card.html` if the copy changes.

## Assumptions to confirm
- Advent window **Dec 1–25** (24 doors + Christmas gold). If `start_date`/`end_date` differ, no CSS
  change is needed — styling follows the generator's `.advent` / `.today` / `.future` / `.missing`
  classes automatically.
- Evergreen browsers only (uses `:is()`, `aspect-ratio`, `color-mix()`, CSS custom properties) — per
  the client, no legacy fallbacks required.

## Source
Built against `perladvent/WWW-AdventCalendar@main` (`share/templates/{page,calendar,article}.mhtml`
+ `style.css`). See `github.md` in the project root.
