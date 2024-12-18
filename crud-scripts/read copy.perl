#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use DBI;
use JSON;

# Crear un objeto CGI para manejar los datos del formulario
my $cgi = CGI->new();

# Capturar los parámetros enviados desde el formulario
#my $name    = $cgi->param('name');

# Imprimir el encabezado HTTP para devolver JSON
print $cgi->header('application/json;charset=UTF-8');

# Conectar a la base de datos
my $dbh = DBI->connect("DBI:MariaDB:database=mascotas;host=dbpets;port=3306", 'root', 'admin', { RaiseError => 1, AutoCommit => 1 })
  or die to_json({ error => "Error al conectar a la base de datos: " . DBI->errstr });

# Consulta SQL para insertar los datos
my $sql = 'SELECT * from pet';
my $sth = $dbh->prepare($sql)
  or die to_json({ error => "Error al preparar la consulta: " . $dbh->errstr });

  

# Ejecutar la consulta
eval {
    $sth->execute()
      or die "Error al ejecutar la consulta: " . $sth->errstr;
};

if ($@) {
    print to_json({ error => "Error durante la inserción: $@" });
} else {

  my @pets;  # Array para los registros
while (my $row = $sth->fetchrow_hashref) {
    push @pets, {
        id     => $row->{id},
        name     => $row->{name},
        owner => $row->{owner},
        species  => $row->{species},
        sex  => $row->{sex},
        birth  =>$row->{birth},
        death  =>$row->{death},
    };
}
# Convertir el array a JSON
my $json = encode_json(\@pets);
    # Respuesta JSON de éxito
    print to_json({
        mensaje => "Datos leidos exitosamente",
        data    => \@pets,
    });
}

# Finalizar la declaración y desconectar
$sth->finish();
$dbh->disconnect();
