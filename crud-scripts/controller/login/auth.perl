#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use CGI::Carp;
use CGI::Session;
use DBI;
use JSON;

my $cgi = CGI->new(); # create new CGI object

# Capturar los parámetros enviados desde el formulario
my $email      = $cgi->param('email');
my $contrasena = $cgi->param('contrasena');

# Validar los datos de entrada
if (!$email || !$contrasena) {
    print $cgi->header('application/json;charset=UTF-8');
    print to_json({ error => "Todos los campos son obligatorios" });
    exit;
}

# Validar que el email tenga un formato correcto
if ($email !~ /^[a-zA-Z0-9_.+-]+\@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$/) {
    print $cgi->header('application/json;charset=UTF-8');
    print to_json({ error => "El correo electrónico no es válido" });
    exit;
}

# Conectar a la base de datos
my $dsn = "DBI:MariaDB:database=datos;host=dbpets;port=3306";
my $user = "root";
my $password = "admin";

my $dbh = DBI->connect($dsn, $user, $password, { RaiseError => 1, AutoCommit => 1 });
if (!$dbh) {
    print $cgi->header('application/json;charset=UTF-8');
    print to_json({ error => "Error al conectar a la base de datos: " . DBI->errstr });
    exit;
}

# Consulta SQL
my $sql = 'SELECT * FROM usuarios WHERE email = ? AND contrasena = ?';
my $sth = $dbh->prepare($sql);

if (!$sth) {
    print $cgi->header('application/json;charset=UTF-8');
    print to_json({ error => "Error al preparar la consulta: " . $dbh->errstr });
    $dbh->disconnect();
    exit;
}

# Ejecutar la consulta
eval {
    $sth->execute($email, $contrasena);
};

if ($@) {
    print $cgi->header('application/json;charset=UTF-8');
    print to_json({ error => "Error durante la inserción: $@" });
    exit;
}

# Verificar si el usuario existe
my $row = $sth->fetchrow_hashref();
if ($row) {
    CGI::Session->name("PW1");
    my $session_id = $cgi->cookie('SESSION_ID') || undef;
    my $session = CGI::Session->new("driver:File", $session_id, {Directory => '/usr/local/apache2/cgi-bin/controller/tmp'});

    # Validar si la sesión se creó correctamente
    if (!$session) {
        print $cgi->header('application/json;charset=UTF-8');
        print to_json({ error => "No se pudo inicializar la sesión" });
        exit;
    }

    # Limpiar y configurar la sesión
    $session->clear(["_IS_LOGGED_IN"]);
    $session->expire(_IS_LOGGED_IN => '+1h');
    $session->param('_EMAIL', $email);
    $session->flush();

    my $cookie = $cgi->cookie(-name => 'SESSION_ID', -value => $session->id, -expires => '+10m');
    print $cgi->header(-type => 'application/json;charset=UTF-8', -cookie => $cookie);

    print to_json({
        status   => 'OK',
        mensaje  => "Usuario autentificado",
        email    => $email
    });
} else {
    print $cgi->header('application/json;charset=UTF-8');
    print to_json({
        status   => 'ERROR',
        mensaje  => "Usuario NO autentificado",
        email    => undef
    });
}

# Finalizar la declaración y desconectar
$sth->finish();
$dbh->disconnect();

