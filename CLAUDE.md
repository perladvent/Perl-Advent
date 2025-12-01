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

```bash
# Build entire site
./script/build-site.sh

# Build single year (faster for testing)
./script/build-site.sh --single-year 2025

# Simulate specific date (useful for testing calendar behavior)
./script/build-site.sh --today 2025-12-15

# Build and serve locally
./script/build-site.sh --single-year 2025
cpm install -g App::HTTPThis
http_this --autoindex out/
# Visit http://127.0.0.1:7007/2025/
```

### Preview Incoming Articles
```bash
# Renders all incoming articles with sequential December dates
perl script/render-incoming.pl
http_this --autoindex out/2025
```

### Annual Maintenance (run in January)
```bash
# Add previous year to archives database
./year2yaml 2024

# Prepare for new year
./script/prepare-new-year.sh
```

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
`script/build-site.sh` performs these steps:
1. Generate archive pages from `archives.yaml` using `mkarchives`
2. For each year 2011-2025:
   - Copy static assets to `out/YEAR/`
   - Run `advcal -c advent.ini -o ../out/YEAR` to generate HTML
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
4. Test with `--today` flag to simulate publication date

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
