# Feature image + og:image — generator integration

**Decision:** the article's share image is the **first `<img>` in the post body**,
falling back to a site-wide default card when a post has no image.

Two files change in `WWW::AdventCalendar`. No new author boilerplate — authors just
embed images in their POD as they do today; the first one becomes the share image.

---

## 1. Article.pm — expose the first image

`body_html` is already built from the POD. Add a helper that pulls the first image
`src` out of it (absolute URL), or undef if there is none:

```perl
has og_image => (
    is      => 'ro',
    isa     => 'Maybe[Str]',
    lazy    => 1,
    builder => '_build_og_image',
);

sub _build_og_image {
    my ($self) = @_;
    # first <img src="..."> in the rendered body
    if ( $self->body_html =~ /<img\b[^>]*\bsrc\s*=\s*["']([^"']+)["']/i ) {
        return $1;
    }
    return undef;   # page.mhtml supplies the default
}
```

If image srcs in posts are relative (e.g. `2026-12-17/diagram.png`), make them
absolute against the calendar's base URL when you emit the tag (below).

---

## 2. page.mhtml — emit the Open Graph / Twitter tags

Add to `<head>` (after the existing `<link rel="stylesheet">`). `$article` is already
passed to the page; on the index it is undef, so we fall back to the default card and
the calendar title.

```mason
% my $base   = $calendar->uri // 'https://perladvent.org/' . $calendar->year . '/';
% my $img    = ($article && $article->og_image) || 'og-default.png';
% my $abs_img = $img =~ m{^https?://} ? $img : $base . $img;
% my $og_title = $article ? $article->title : $calendar->title;
% my $og_desc  = $article ? ($article->topic // '') : ($calendar->tagline // '');
% my $og_url   = $base . ($article ? $article->date->ymd . '.html' : 'index.html');
    <meta property="og:type"        content="<% $article ? 'article' : 'website' %>" />
    <meta property="og:site_name"   content="<% $calendar->title |h %>" />
    <meta property="og:title"       content="<% $og_title |h %>" />
    <meta property="og:description" content="<% $og_desc  |h %>" />
    <meta property="og:url"         content="<% $og_url   |h %>" />
    <meta property="og:image"       content="<% $abs_img  |h %>" />
    <meta property="og:image:width"  content="1200" />
    <meta property="og:image:height" content="630" />
    <meta name="twitter:card"        content="summary_large_image" />
    <meta name="twitter:title"       content="<% $og_title |h %>" />
    <meta name="twitter:description" content="<% $og_desc  |h %>" />
    <meta name="twitter:image"       content="<% $abs_img  |h %>" />
```

- `og-default.png` (this folder → `assets/og-default.png`) ships next to `style.css`
  in each year's output dir. 1200×630, the sizes declared above.
- Author-supplied first images should ideally be ~1200×630; the CSS feature banner
  (`.feature-image`) crops with `object-fit: cover`, but social crawlers use the raw file.

---

## 3. Feature banner on the page (optional but recommended)

`perl-advent-2026.css` already styles `.feature-image` (full-bleed, ≤420px,
`object-fit: cover`). To show the first image as a banner at the top of an article,
add to `article.mhtml`, just inside `<div id="content">` before the `<h1 class="title">`:

```mason
% if ($article->og_image) {
        <div class="feature-image"><img src="<% $article->og_image |h %>" alt="" /></div>
% }
```

The same first image then serves as both the on-page banner and the share card.
