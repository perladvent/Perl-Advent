#!/usr/bin/perl -U
use File::HomeDir;

unlink( File::HomeDir->users_home('w') );
