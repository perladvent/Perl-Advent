# Preparing for a New Calendar Year

Much of this process is automated, but there are a few things which need to be
updated by hand every year. Hopefully we can automate more and more, but this
should be a good starting point checklist for what needs to be done before a
new calendar can be launched.

## Create Scaffolding

```shell
mkdir -p 2024
cp 2023/advent.ini 2024
```

## Find and Replace

The calendar year is hard coded in various places. Update them to the current
year in:

```shell
perl -pi -e 's/2023/2024/g' \
    in-season.html          \
    script/build-site.sh    \
    script/stats.sh         \
    2024/advent.ini
```
