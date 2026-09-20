# Single-article preview

**Date:** 2026-09-20
**Status:** Approved (design)

## Problem

Authors drafting an article in `2026/incoming/` want to see it rendered with the
new 2026 re-skin quickly, without building the whole calendar or going through
`render-incoming.pl`'s full `build-site.sh` path. The just-shipped UAT flow
(`make uat` → `script/uat-preview.sh`) already knows how to render 2026 with the
`inc/` fork and the year-local templates; we want that same rendering for a
single article, behind one dead-simple command.

## Goals

- One command that renders a single `.pod` and serves it, so the author opens a
  URL and sees their article with the real re-skin.
- Reuse the proven `uat-preview.sh` mechanics (fork on `PERL5LIB`, temp ini
  pointing `article_dir` at a chosen dir, `--today` so the door is open,
  copy-and-clean-up of images, `rm -rf out/YEAR` for a clean slate).
- Leave the tree clean afterwards — never touch `2026/articles/` or leave stray
  assets behind.
- No python dependency: serve with `http_this` (App::HTTPThis).

## Non-goals

- Filesystem watching / auto-rebuild. To see an edit, re-run the command.
- Multi-year support. Hardcoded to `YEAR=2026`, matching `uat-preview.sh`.
- Rendering more than one article (that is what `make uat` is for).
- Changing the existing `uat` / `uat-serve` targets (they stay on python).

## Design

### New script: `script/preview-article.sh`

Usage: `script/preview-article.sh <path-to-article.pod>`

Hardcoded `YEAR=2026`. Steps:

1. **Validate** the argument: exactly one path, it exists, and it ends in
   `.pod`. Otherwise print usage and exit non-zero.
2. **Clean slate:** `rm -rf out/2026 && mkdir -p out/2026` (same as
   `uat-preview.sh`, so a previous run never misleads).
3. **Stage the article:** create a temp article dir inside the year,
   `2026/.preview/`, and copy the given `.pod` into it as a fixed dated file
   `2026-12-01.pod` so `advcal` picks it up as door 1.
4. **Stage images:** scan the `.pod` for referenced image filenames (e.g.
   `src="..."` targets) and copy those files, when found in the article's own
   directory, into `2026/share/static/`. Track exactly which files we add so
   cleanup removes only those; if a file already exists in `share/static`,
   leave it and use the real one (same guard as `uat-preview.sh`).
5. **Render:** write a temp ini `2026/.advent.preview.ini` from `advent.ini`
   with `article_dir` rewritten to `.preview` (`share_dir` unchanged, so the
   year-local templates still load), then, from inside `2026/`, run
   `advcal -c .advent.preview.ini -o ../out/2026 --today 2026-12-25` with
   `PERL5LIB` prefixed by `inc/WWW-AdventCalendar/lib`.
6. **Cleanup on exit:** a `trap` removes `2026/.preview/`, the temp ini, and the
   copied images — whether the render succeeds or fails.
7. **Report:** print the direct URL
   `http://127.0.0.1:$PREVIEW_PORT/2026/2026-12-01.html` and the serve hint.
   (`PREVIEW_PORT` defaults to `8026` when unset, only for the printed hint.)

The article always renders as `2026-12-01.html` regardless of its incoming
slug, because the preview only ever stages one article.

### Makefile targets

Variables (all overridable on the command line):

- `PREVIEW_PORT ?= 8026` — serve port.
- `PREVIEW_HOST` — unset by default, so `http_this` uses its safe loopback
  default. Set it (e.g. to a tailnet IP) to pass `--host $(PREVIEW_HOST)` and
  expose the preview on that interface.
- `ARTICLE` — required; the path to the `.pod` to preview.

Targets (both `.PHONY`):

- **`make preview ARTICLE=2026/incoming/foo.pod`** — build then serve. Runs
  `script/preview-article.sh $(ARTICLE)`, then
  `http_this out --port $(PREVIEW_PORT) $(if $(PREVIEW_HOST),--host $(PREVIEW_HOST),) --autoindex`.
  One command; open the printed URL.
- **`make preview-build ARTICLE=...`** — build only (runs the script, no
  serve), for when a server is already pointed at `out/` and you just refresh.

Both targets guard `ARTICLE`: if unset, print a one-line usage message
(`usage: make preview ARTICLE=2026/incoming/foo.pod`) and exit non-zero, rather
than running the script with an empty path.

`http_this` binds to loopback by default (it now requires `--all` to reach every
interface), so the default `make preview` is safe on a shared network; opting
into a tailnet is an explicit `PREVIEW_HOST=...`.

## Error handling

- Bad/missing `ARTICLE` → make target prints usage, exits non-zero.
- Non-`.pod` or missing file → script prints usage, exits non-zero.
- `advcal` failure → `set -euo pipefail` propagates the non-zero exit; the
  `trap` still cleans up the temp dir, ini, and copied images.

## Testing / verification

- `make preview ARTICLE=<an existing 2026 incoming article>` renders and serves;
  the printed URL shows the article with the re-skin, and door 1 is open on
  `/2026/`.
- After the run (and after Ctrl-C), `git status` is clean: no `.preview/`, no
  `.advent.preview.ini`, no added files under `share/static`, `2026/articles/`
  untouched.
- `make preview` with no `ARTICLE` prints usage and exits non-zero.
- `PREVIEW_PORT=9000 make preview ARTICLE=...` serves on 9000.
