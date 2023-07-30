# Perl Advent Calendar

The [Perl Advent Calendar](https://perladvent.org) is a series of
articles that run from December 1 to 25 each year.

## Authors

Raise an issue suggesting your topic.

Fork the repo and start a new article. The script will prompt you
for a few things and will create a new file for you under *YEAR*/incoming/.

```bash
$ perl script/new_article
```

Edit your article, and test it as you work:

```bash
$ perl t/article_pod.t 2023/incoming/your-article.pod
```

When you are satisfied, create a pull request. You can keep working
on the article and pushing updates to your fork; the pull request
will automatically see the updates.

## The website

### 1. Build root files

To create some root files from `archives.yaml`:

- `archives.html` - list of advent calendars
- `archives-AZ.html` - list of modules
- `archives-Yd.html` - list of articles

Execute the following script:

```bash
$ perl mkarchives .
```

### 2. Build all (recent) advent calendars

```bash
cpm install -g WWW::AdventCalendar App::HTTPThis
```

Then build all recent calendars

```bash
$ for year in $(seq 2011 2023); do cd $year && advcal -c advent.ini -o `pwd` && cd ..; done
```

### 3. Test (locally)

Start HTTP webserver in one line:

```bash
$ http_this --autoindex .
```

You can visit [http://127.0.0.1:7007/](http://127.0.0.1:7007/)

