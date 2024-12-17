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

my $course = $session->param('course');

print '03_sesion_variable_read.pl';
print '<br/>';
print $session;
print '<br/>';
print $CGISESSID;
print '<br/>';
print 'Se RECUPERÓ dato en variable de sesión $course=' . $course;
print '<br/>';
print 'name = '.$session->name();

# expire the session itself after 1 idle hour
#$session->expire('+1h');

print '<br/>';
print '<br/>';
print '<a href="./">Regresar ...</a>';