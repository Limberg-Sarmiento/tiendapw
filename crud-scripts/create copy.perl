#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use DBI;
use JSON;

# Crear un objeto CGI para manejar los datos del formulario
my $cgi = CGI->new();

# Capturar los parámetros enviados desde el formulario
my $name    = $cgi->param('name');
my $owner   = $cgi->param('owner');
my $species = $cgi->param('species');
my $sex     = $cgi->param('sex');
my $birth   = $cgi->param('birth');
my $death   = $cgi->param('death');

# Si no se ha proporcionado fecha de fallecimiento, establecer como NULL
if (!$death) {
    $death = undef;  # Asignar undef para representar NULL en la base de datos
}

# Imprimir el encabezado HTTP para devolver JSON
print $cgi->header('application/json;charset=UTF-8');

# Conectar a la base de datos
my $dbh = DBI->connect("DBI:MariaDB:database=mascotas;host=dbpets;port=3306", 'root', 'admin', { RaiseError => 1, AutoCommit => 1 })
  or die to_json({ error => "Error al conectar a la base de datos: " . DBI->errstr });

# Consulta SQL para insertar los datos
my $sql = 'INSERT INTO pet (name, owner, species, sex, birth, death) VALUES (?, ?, ?, ?, ?, ?)';
my $sth = $dbh->prepare($sql)
  or die to_json({ error => "Error al preparar la consulta: " . $dbh->errstr });

# Ejecutar la consulta
eval {
    $sth->execute($name, $owner, $species, $sex, $birth, $death)
      or die "Error al ejecutar la consulta: " . $sth->errstr;
};

if ($@) {
    print to_json({ error => "Error durante la inserción: $@" });
} else {
    # Respuesta JSON de éxito
    print to_json({
        mensaje => "Datos registrados exitosamente",
        name    => $name,
        owner   => $owner,
        species => $species,
        sex     => $sex,
        birth   => $birth,
        death   => $death,
    });
}

# Finalizar la declaración y desconectar
$sth->finish();
$dbh->disconnect();
