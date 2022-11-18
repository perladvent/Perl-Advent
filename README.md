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
$ perl t/article_pod.t 2022/incoming/your-article.pod
```

When you are satisfied, create a pull request. You can keep working
on the article and pushing updates to your fork; the pull request
will automatically see the updates.

## The website

### 1. Build root files
To create some root files from `archives.yaml`:
- `archive.html` - list of advent calendars
- `archives-AZ.html` - list of modules
- `archives-Yd.html` - list of articles

Execute the following script:
```bash
$ perl mkarchives
```

### 2. Build all (recent) advent calendars
```bash
$ sudo cpanm WWW::AdventCalendar
```

Then build all recent calendars
```bash
$ for year in 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021; do cd $year && advcal -c advent.ini -o `pwd` && cd ..; done
```

### 3. Test (locally)
Install `Plack`:
```bash
$ sudo cpanm Plack
```

Start HTTP webserver in one line:
```bash
$ plackup -MPlack::App::Directory -e 'Plack::App::Directory->new(root=>".");' -p 8080
```

You can visit [http://localhost:8080/index.html](http://localhost:8080/index.html)

