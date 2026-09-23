# Perl Advent Calendar

The [Perl Advent Calendar](https://perladvent.org) is a series of
articles that run from December 1 to 25 each year.

## Authors

Raise an issue suggesting your topic.

Fork the repo and start a new article. This prompts you for a few things
and creates a new file for you under *YEAR*/incoming/.

```bash
make new-article
```

It writes to the current calendar year by default. Override that (or any
other field) with a make variable:

```bash
make new-article YEAR=2026
```

(The underlying script is `perl script/new_article`; run it directly if you
prefer, e.g. `perl script/new_article --year 2026`.)

Edit your article, and test it as you work:

```bash
perl t/article_pod.t 2023/incoming/your-article.pod
```

To see your article rendered with the real calendar styling, preview just
that one file and open the URL it prints:

```bash
make preview ARTICLE=2026/incoming/your-article.pod
```

(Run `make init` once first to fetch the build submodules. To share the
preview with others on your tailnet, use `make preview-tailnet` instead.
`make help` lists every build target.)

When you are satisfied, create a pull request. You can keep working
on the article and pushing updates to your fork; the pull request
will automatically see the updates.

## The website

Most build and preview tasks are wrapped in the `Makefile` — run `make help`
to list every target and its overridable variables. The common ones:

- `make site` — build the whole site into `out/` (all years)
- `make preview ARTICLE=YEAR/incoming/foo.pod` — render and serve a single article

Run `make init` once in a fresh checkout to fetch the build submodules. The
steps below are the underlying manual commands, kept for reference.

**Using Docker?** See [DOCKER.md](DOCKER.md) for containerized build and preview instructions.

### 0. Add previous year to `archives.yaml`

Currently this needs to be run manually once per year, in the new year.

```bash
./year2yaml $(perl -MTime::Piece -le 'print localtime->year - 1')
```

### 1. Build root files

To create some root files from `archives.yaml`:

- `archives.html` - list of advent calendars
- `archives-AZ.html` - list of modules
- `archives-Yd.html` - list of articles

Execute the following script:

```bash
perl mkarchives .
```

### 2. Build all (recent) advent calendars

```bash
cpm install -g WWW::AdventCalendar App::HTTPThis
```

Then build all recent calendars

```bash
for year in $(seq 2011 2026); do cd $year && advcal -c advent.ini -o `pwd` && cd ..; done
```

### 3. Test (locally)

Start HTTP webserver in one line:

```bash
http_this --autoindex .
```

You can visit [http://127.0.0.1:7007/](http://127.0.0.1:7007/)

## Editors

For notes on the editing process, please refer to [EDITING.md](EDITING.md)
