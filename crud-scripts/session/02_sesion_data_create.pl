#!/usr/bin/perl
use strict;
use warnings;
use CGI::Carp; # send errors to the browser, not to the logfile
use CGI;
use CGI::Session;
use utf8;

my $cgi = CGI->new(); # create new CGI object
print $cgi->header('text/html');

#CGI::Session->name("PW1");
my $session = CGI::Session->load('f881f03517d2ed0b0dcbcfaa9c21a14b');
my $CGISESSID = $session->id();

# storing data in the session
$session->param('course', 'Programación Web 1');
# $session->param(-name=>'course', -value=>'Programación Web 1');
# $session->param(-name=>'course', -value=>{
#                                "pw1"  => 1,
#                                "est"  => 1,
#                                "ada"  => 2
#                               });

my $course = $session->param('course');

print '02_sesion_variable.pl';
print '<br/>';
print $session;
print '<br/>';
print $CGISESSID;
print '<br/>';
print 'Se CREÓ dato en variable de sesión $course=' . $course;
print '<br/>';
print 'name = '.$session->name();

print '<br/>';
print '<br/>';
print '<a href="./">Regresar ...</a>';