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


print '06_sesion_destroy.pl';
print '<br/>';
print $session;
print '<br/>';
print $CGISESSID;
print '<br/>';
print 'Se ELIMINÓ sesión';
print '<br/>';
print 'name = '.$session->name();

# delete the session for good
$session->delete();

print '<br/>';
print '<br/>';
print '<a href="./">Regresar ...</a>';