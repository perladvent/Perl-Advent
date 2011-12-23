#!/usr/bin/perl
use DateTime;
use DateTime::Calendar::Discordian;

print DateTime::Calendar::Discordian->
  #Its parameters are even unnecessarily verbose!
  from_object( object=>DateTime->now() )->
  strftime('%{%A, %B %d%}, %Y Year Of Lady Discord');
