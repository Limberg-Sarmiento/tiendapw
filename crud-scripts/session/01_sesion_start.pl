#!/usr/bin/perl
use strict;
use warnings;
use CGI::Carp; # send errors to the browser, not to the logfile
use CGI;
use CGI::Session;

# apt-cache search -n libcgi
# libcgi-session-perl - persistent session data in CGI applications
# Install the CGI::Session module.
# sudo apt-get install libcgi-session-perl
# sudo /etc/init.d/apache2 restart
# https://metacpan.org/pod/CGI::Session
# https://metacpan.org/pod/CGI::Session::Tutorial

CGI::Session->name("PW1");
my $cgi = CGI->new(); # create new CGI object
print $cgi->header('text/html');

my $session = CGI::Session->new();
#my $session = new CGI::Session("driver:File", undef, {Directory=>'/tmp'});

# getting the effective session id:
my $CGISESSID = $session->id();

# clearing a certain session parameter
$session->clear(["_IS_LOGGED_IN"]);

# expire '_IS_LOGGED_IN' flag after 10 idle minutes:
$session->expire(_IS_LOGGED_IN => '+10m');

print '01_sesion_start.pl';
print '<br/>';
print $session;
print '<br/>';
print $CGISESSID;

print '<br/>';
print '<br/>';

# print $session->header(); #????

print 'SPECIAL NAMES';
print '<br/>';
# stores the ID of the session
my $ID_SESSION = $session->id();
print '_session_id = ' . $ID_SESSION;
print '<br/>';
# stores the creation date of the session
print '_session_ctime = '.$session->ctime();
print '<br/>';
# stores the last access time for the session
print '_session_atime = '.$session->atime();
print '<br/>';
# stores expiration date for the session
print '_session_etime = '.$session->etime();
print '<br/>';
print 'name = '.$session->name();
print '<br/>';
print '<br/>';

print '<a href="02_sesion_data_create.pl?id_session='.$ID_SESSION.'">02_sesion_data_create.pl</a>';
print '<br/>';
print '<br/>';
print '<a href="./">Regresar ...</a>';