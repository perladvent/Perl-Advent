# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

The Perl Advent Calendar is a static site generator that publishes 24-25 Perl module articles annually from December 1-25. The site is deployed to GitHub Pages at https://perladvent.org.

## Build System Architecture

The build system follows this flow:
```
POD articles (YEAR/articles/) → WWW::AdventCalendar processes →
HTML pages generated → Static files copied → out/ directory → GitHub Pages
```

### Core Technologies
- **WWW::AdventCalendar** - Main engine converting POD to HTML (git submodule in `inc/WWW-AdventCalendar`)
- **Pod::Elemental::Transformer::SynHi** - Syntax highlighting for code blocks
- **Text::VimColor** + **vim-perl** - Vim-based syntax highlighting
- **PPI::HTML** - Perl code parsing and HTML generation

### Directory Structure
- **YEAR/articles/** - Published articles in `YYYY-MM-DD.pod` format
- **YEAR/incoming/** - Work-in-progress articles before date assignment
- **YEAR/share/static/** - Images and assets specific to that year
- **YEAR/advent.ini** - Year-specific configuration (colors, metadata)
- **script/** - Build and maintenance scripts
- **inc/** - Git submodules for forked dependencies
- **out/** - Generated static HTML (not committed)

## Common Development Commands

### Initializing Submodules
```bash
# Initialize and update git submodules (in inc/)
make init
# Runs: git submodule update --init --recursive
# Useful for linked worktrees, which don't populate submodules automatically
```

### Creating a New Article
```bash
perl script/new_article
# Creates YEAR/incoming/slug.pod with template
```

### Testing Articles
```bash
# Test specific article
perl t/article_pod.t 2025/incoming/your-article.pod

# Test all articles
prove -lr t/
```

### Assigning Article to Publication Date
```bash
# Find article interactively and assign to December day
find 2025/incoming | fzf | xargs -I {} perl script/assign-date.pl --article {} --day 5 --year 2025

# This moves article to 2025/articles/2025-12-05.pod and creates publish branch/PR
# IMPORTANT: Images must be moved manually from incoming/ to share/static/
```

### Building the Site

**The Makefile is the entry point.** Run `make help` to list every target.
The build scripts source `script/use-forks.sh`, which puts the `inc/` forks on
`PATH`/`PERL5LIB`. To run `advcal` by hand, source the forks in the same bash
command, from the repo root: `source script/use-forks.sh && cd 2026 && advcal ...`.
The stock CPAN `advcal` lacks the fork's options (e.g. `--https`).

```bash
# Build entire site
make site

# Build single year (faster for testing)
make site SINGLE_YEAR=2026

# Simulate specific date (useful for testing calendar behavior)
make site SINGLE_YEAR=2026 TODAY=2026-12-15

# Build the 2026 UAT fixture calendar into out/2026 (default DAY=2026-12-06)
make uat DAY=2026-11-01

# Serve out/ locally
make uat-serve
# Visit http://127.0.0.1:8026/2026/
```

### Preview Incoming Articles
```bash
# Render one article as door 1 with the current theme, then serve it
make preview ARTICLE=2026/incoming/your-article.pod
# Visit http://127.0.0.1:8026/2026/2026-12-01.html
```

### Annual Maintenance (run in January/February)

See `ANNUAL-UPDATES.md` for the full step-by-step guide. In brief:

```bash
# 1. Add previous year to archives database
./year2yaml 2025

# 2. Create new year scaffold and update year references site-wide
./script/prepare-new-year.sh

# 3. Create empty directories tracked by git. Not articles/: advcal reads
#    every file there, so a .gitkeep breaks December builds, and
#    assign-date.pl creates it with the first article.
NEW_YEAR=$(date +%Y)
mkdir -p "$NEW_YEAR/incoming" "$NEW_YEAR/share/static"
touch "$NEW_YEAR/incoming/.gitkeep" "$NEW_YEAR/share/static/.gitkeep"
```

`year2yaml` classifies topics as `module` (links to MetaCPAN) when the topic
contains `::`, and as `topic` otherwise. Review `archives.yaml` afterwards for
single-word CPAN modules that lack `::` (e.g. `LWP`, `Moose`).

## Article Format (POD)

Articles are written in POD (Plain Old Documentation) with these required headers:
```pod
Author: Your Name <email@example.com>
Title: Article Title
Topic: Module::Name
```

### Common POD Patterns

**Raw HTML blocks**:
```pod
=for html
  <img src="image-name.png" alt="description" style="float: right; margin: 0 0 1em 1em; width: 300px;">
```

Note: Both `=for html` and `=for :html` are valid POD syntax and work correctly in this codebase.

**Syntax-highlighted code blocks**:
```pod
=begin perl

    my $code = 'with syntax highlighting';

=end perl
```

**Bullet lists**:
```pod
=for :list
* Item one
* Item two
```

**Links**:
```pod
L<Module::Name>  # Auto-links to CPAN
L<text|https://url.com>  # External link
```

## Image Handling

### Storage Location
- Place images in `YEAR/share/static/` directory
- During build, files are copied to `out/YEAR/`
- Reference in articles with relative path: `src="image-name.png"`

### Common Issue: Images Not Rendering
1. **Wrong directory**: Images must be in `YEAR/share/static/` not `YEAR/incoming/`
2. **Not copied during assign-date**: The script reminds you, but images must be moved manually
3. **Missing indentation**: HTML content in `=for html` blocks should be indented

Example:
```pod
=for html
  <img src="image.png" alt="description">
```

## Important Conventions

### Article Dates
- Articles publish as `YYYY-12-DD.html` where DD is 01-25
- The published HTML filename comes from the POD filename
- If file is `2025-12-01.pod`, it publishes as `2025-12-01.html`
- **Note**: The calendar may display it on Dec 3 if that's when it's scheduled in the build

### Testing Requirements
- All articles must have valid POD syntax
- Required headers: Author, Title, Topic
- Tests run automatically on all PRs via GitHub Actions

### Git Workflow
- **Authors**: Fork → create article in incoming/ → PR to main
- **Editors**: Review → merge to main → assign-date.pl → publish branch → PR
- **Automation**: GitHub Actions deploys to Pages in December/January

## Build System Details

### Main Build Script
`script/build-site.sh` (run via `make site`) performs these steps:
1. Generate archive pages from `archives.yaml` using `mkarchives`
2. For 1999 and each year from 2011 (the `seq` range in the script; 2000-2010
   are copied verbatim):
   - Copy static assets to `out/YEAR/`
   - Run `advcal -c advent.ini -o ../out/YEAR --https` to generate HTML
   - When advcal wrote its pre-season feed, `script/coming-soon-feed.sh` swaps
     in the static `coming-soon.atom.xml` (see the script's header)
3. Copy root assets (images, CSS, HTML)
4. Convert Markdown docs to HTML

### Configuration Files
- **advent.ini**: Per-year config (title, colors, directories, editor info)
- **archives.yaml**: Historical database of all articles (populated via `year2yaml`)
- **.perl-version**: Required Perl version (5.36.0)
- **cpanfile**: Perl dependencies

### GitHub Actions
- **test.yml**: Runs POD validation tests on all PRs
- **build.yml**: Builds site and deploys to GitHub Pages (December-January only)

## Debugging Tips

### Article Not Showing
1. Check filename matches `YYYY-MM-DD.pod` format
2. Verify it's in `articles/` not `incoming/`
3. Check advent.ini `end_date` includes that date
4. Simulate the publication date with `make site SINGLE_YEAR=YYYY TODAY=YYYY-12-DD`

### Image Not Loading
1. Verify image is in `YEAR/share/static/`
2. Check HTML content in `=for html` blocks is properly indented
3. Rebuild and check `out/YEAR/` contains the image
4. Verify HTML isn't escaped in generated file

### Build Failures
1. Check POD syntax: `perl t/article_pod.t path/to/article.pod`
2. Verify required headers present
3. Check for unescaped special characters in POD
4. Review GitHub Actions logs for specific errors

## Editorial Guidelines

From EDITING.md:
- **Light touch editing**: Preserve author's voice while fixing grammar/spelling
- **Christmas themes welcome but optional**: Festive elements encouraged but not required
- **Technical accuracy required**: Verify all code examples work
- **Graphics encouraged**: Images, GIFs, SVGs add visual interest
- Use GitHub PR suggestions for typo fixes
- Post-merge edits acceptable for minor fixes

### Key Dates
- September 30: Article proposal deadline
- October 1: Acceptance notifications
- November 1: First draft due
- November 15: Final edits due
- December 1 (12:00 AM EST): Articles go live
