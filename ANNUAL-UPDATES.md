# Preparing for a New Calendar Year

Run the following steps once the previous December's articles are complete
(typically in January or February):

## 1. Archive the previous year

Add the previous year's topics to `archives.yaml`:

```bash
./year2yaml YYYY
```

For example, after the 2025 calendar:

```bash
./year2yaml 2025
```

`year2yaml` reads the `Topic:` header from each article and appends a new
section to `archives.yaml`.  Entries are classified as `module` (linked to
MetaCPAN) when the topic name contains `::`, and as `topic` otherwise.
Single-word CPAN modules without `::` in their name (e.g. `LWP`, `Moose`)
will be classified as `topic` — edit `archives.yaml` by hand afterwards if
you want those to carry a MetaCPAN link.

Comma-separated topics on a single `Topic:` line are split into individual
entries automatically.  Space-separated module names are also split, provided
every space-delimited token contains `::`.

## 2. Prepare the new year's scaffold

```bash
./script/prepare-new-year.sh
```

This script:

* Creates `YYYY/advent.ini` (copied from the previous year with the year
  updated throughout)
* Updates year references in `in-season.html`, `README.md`,
  `.github/pull_request_template.md`, `script/build-site.sh`, and
  `script/stats.sh`

After the script runs, create the empty directories that the build system
expects and add `.gitkeep` files so they are tracked by git:

```bash
NEW_YEAR=$(date +%Y)
mkdir -p "$NEW_YEAR/articles" "$NEW_YEAR/incoming" "$NEW_YEAR/share/static"
touch "$NEW_YEAR/articles/.gitkeep" \
      "$NEW_YEAR/incoming/.gitkeep" \
      "$NEW_YEAR/share/static/.gitkeep"
```

## 3. Review and commit

Check the updated files, then commit everything:

```bash
git add archives.yaml year2yaml \
        "$NEW_YEAR/" \
        in-season.html README.md \
        .github/pull_request_template.md \
        script/build-site.sh script/stats.sh
git commit -m "chore: archive PREV_YEAR and prepare scaffold for NEW_YEAR"
```
