#!/usr/bin/perl
use strict;
use warnings;
use CGI::Carp; # send errors to the browser, not to the logfile
use CGI;

my $cgi = CGI->new(); # create new CGI object
print $cgi->header('text/html');

print '<a href="01_sesion_start.pl">01_sesion_start.pl</a>';
print '<br/>';
print '<a href="02_sesion_data_create.pl">02_sesion_data_create.pl</a>';
print '<br/>';
print '<a href="03_sesion_variable_read.pl">03_sesion_variable_read.pl</a>';
print '<br/>';
print '<a href="05_sesion_delete.pl">05_sesion_delete.pl</a>';
print '<br/>';
print '<a href="06_sesion_destroy.pl">06_sesion_destroy.pl</a>';
print '<br/>';