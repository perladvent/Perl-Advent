use strict;
use warnings;

requires 'HTML::Escape';
requires 'Text::Markdown';
requires 'URI';
requires 'WWW::AdventCalendar';
requires 'YAML::XS';

on 'test' => sub {
    requires 'Mojolicious';
    requires 'Path::Tiny';
};

on 'develop' => sub {
    requires 'App::HTTPThis';
    requires 'Getopt::Kingpin';
    requires 'Plack';
};
