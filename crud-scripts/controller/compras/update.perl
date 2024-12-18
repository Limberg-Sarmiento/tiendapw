#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use DBI;
use JSON;

# Crear un objeto CGI para manejar los datos del formulario
my $cgi = CGI->new();

# Capturar los parámetros enviados desde el formulario
my $id    = $cgi->param('id');
my $nombre    = $cgi->param('nombre');
my $tipo   = $cgi->param('tipo');
my $precio = $cgi->param('precio');

# Si no se ha proporcionado fecha de fallecimiento, establecer como NULL
if (!$death) {
    $death = undef;  # Asignar undef para representar NULL en la base de datos
}

# Imprimir el encabezado HTTP para devolver JSON
print $cgi->header('application/json;charset=UTF-8');

# Conectar a la base de datos
my $dbh = DBI->connect("DBI:MariaDB:database=datos;host=dbpets;port=3306", 'root', 'admin', { RaiseError => 1, AutoCommit => 1 })
  or die to_json({ error => "Error al conectar a la base de datos: " . DBI->errstr });

# Consulta SQL para insertar los datos
my $sql = 'UPDATE productos SET nombre = ?, tipo = ?, precio = ? WHERE id = ?';
my $sth = $dbh->prepare($sql)
  or die to_json({ error => "Error al preparar la consulta: " . $dbh->errstr });

# Ejecutar la consulta
eval {
    $sth->execute($nombre, $tipo, $precio, $id)
      or die "Error al ejecutar la consulta: " . $sth->errstr;
};

if ($@) {
    print to_json({ error => "Error durante la inserción: $@" });
} else {
    # Respuesta JSON de éxito
    print to_json({
        mensaje => "Datos actualizados exitosamente",
        id => $id,
        nombre    => $nombre,
        precio    => $precio,
        tipo    => $tipo,
    });
}

# Finalizar la declaración y desconectar
$sth->finish();
$dbh->disconnect();