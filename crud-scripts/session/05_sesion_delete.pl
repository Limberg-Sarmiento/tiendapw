#!/usr/bin/perl
use strict;
use warnings;
use CGI::Carp; # send errors to the browser, not to the logfile
use CGI;
use CGI::Session;
use utf8;

my $cgi = CGI->new(); # create new CGI object
print $cgi->header('text/html');

my $session = CGI::Session->load('f881f03517d2ed0b0dcbcfaa9c21a14b');
my $CGISESSID = $session->id();

$session->param('course', ':(...');
my $course = $session->param('course');

print '05_sesion_delete.pl';
print '<br/>';
print $session;
print '<br/>';
print $CGISESSID;
print '<br/>';
print 'Se ACTUALIZÓ dato en variable de sesión $course=' . $course;
print '<br/>';
print 'name = '.$session->name();

print '<br/>';
print '<br/>';
print '<a href="./">Regresar ...</a>';