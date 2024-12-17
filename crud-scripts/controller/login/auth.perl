#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use DBI;
use JSON;

# Crear un objeto CGI para manejar los datos del formulario
my $cgi = CGI->new();

# Capturar los parámetros enviados desde el formulario

my $email      = $cgi->param('email');
my $contrasena = $cgi->param('contrasena');

# Imprimir el encabezado HTTP para devolver JSON
print $cgi->header('application/json;charset=UTF-8');

# Validar los datos de entrada
if (!$email || !$contrasena) {
    print to_json({ error => "Todos los campos son obligatorios" });
    exit;
}

# Validar que el email tenga un formato correcto
if ($email !~ /^[a-zA-Z0-9_.+-]+\@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$/) {
    print to_json({ error => "El correo electrónico no es válido" });
    exit;
}

# Conectar a la base de datos
my $dsn = "DBI:MariaDB:database=datos;host=dbpets;port=3306";
my $user = "root";
my $password = "admin";

my $dbh = DBI->connect($dsn, $user, $password, { RaiseError => 1, AutoCommit => 1 });
if (!$dbh) {
    print to_json({ error => "Error al conectar a la base de datos: " . DBI->errstr });
    exit;
}

# Consulta SQL para insertar los datos
my $sql = 'SELECT * FROM usuarios WHERE email = ? AND contrasena = ?';
my $sth = $dbh->prepare($sql);
if (!$sth) {
    print to_json({ error => "Error al preparar la consulta: " . $dbh->errstr });
    $dbh->disconnect();
    exit;
}
 
# Ejecutar la consulta
eval {
    $sth->execute($email, $contrasena);
};


if ($@) {
    print to_json({ error => "Error durante la inserción: $@" });
} else {
    my $row = $sth->fetchrow_hashref();
     if ( $row ) {
        print to_json({
        status   => 'OK',  # Cambiar el campo a 'exito'
        mensaje => "Usuario autentificado",
        email   => $email
    });
    } else {
        print to_json({
            status   => 'ERROR',  # Cambiar el campo a 'exito'
            mensaje => "Usuario NO autentificado",
            email   => undef
        });
    }
    # Respuesta JSON de éxito
    # Enviar la respuesta JSON de éxito

}

# Finalizar la declaración y desconectar
$sth->finish();
$dbh->disconnect();


