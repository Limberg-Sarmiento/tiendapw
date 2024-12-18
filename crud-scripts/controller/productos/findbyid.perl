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

# Imprimir el encabezado HTTP para devolver JSON
print $cgi->header('application/json;charset=UTF-8');

# Conectar a la base de datos
my $dbh = DBI->connect("DBI:MariaDB:database=datos;host=dbpets;port=3306", 'root', 'admin', { RaiseError => 1, AutoCommit => 1 })
  or die to_json({ error => "Error al conectar a la base de datos: " . DBI->errstr });

# Consulta SQL para insertar los datos
my $sql = 'SELECT * from productos WHERE id = ?';
my $sth = $dbh->prepare($sql)
  or die to_json({ error => "Error al preparar la consulta: " . $dbh->errstr });

  

# Ejecutar la consulta
eval {
    $sth->execute($id)
      or die "Error al ejecutar la consulta: " . $sth->errstr;
};

my $row = $sth->fetchrow_hashref();

if ($@) {
    print to_json({ error => "Error durante la inserción: $@" });
} else {

if ($row) {
    print to_json({
        id => $row->{id},
        nombre => $row->{nombre},
        tipo => $row->{tipo},
        precio => $row->{precio},
        url => $row->{url},
    });
} else {
    print to_json({ error => "Producto no encontrada" });
}
}

# Finalizar la declaración y desconectar
$sth->finish();
$dbh->disconnect();
