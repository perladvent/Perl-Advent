repo: perladvent/WWW-AdventCalendar
branch: main
path: share/templates

## Last sync
date: 2026-09-19T16:24:00Z
commit: (tree 14e350ff26a4 — commit sha not resolved)

### Updated in this project
- Read the real generator templates (page/calendar/article Mason + style.css) to ground the 2026 re-skin.
- Authored `perl-advent-2026.css` as a drop-in replacement for `share/templates/style.css`, targeting the real class names.
- Added optional `advent.js` (dark-mode toggle + localStorage "visited" marks).

## Screen map
| Screen | Built from |
| --- | --- |
| Calendar index (doors) | share/templates/calendar.mhtml + page.mhtml |
| Day / article page | share/templates/article.mhtml + page.mhtml |
| Stylesheet being replaced | share/templates/style.css |
