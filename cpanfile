use strict;
use warnings;

requires 'Text::Markdown';
requires 'WWW::AdventCalendar';
requires 'YAML::XS';

on 'develop' => sub {
    requires 'App::HTTPThis';
    requires 'Plack';
};
