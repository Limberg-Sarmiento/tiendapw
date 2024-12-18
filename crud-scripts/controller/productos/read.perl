#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use DBI;
use JSON;

# Crear un objeto CGI para manejar los datos del formulario
my $cgi = CGI->new();

# Imprimir el encabezado HTTP para devolver JSON
print $cgi->header('application/json;charset=UTF-8');

# Conectar a la base de datos
my $dbh = DBI->connect("DBI:MariaDB:database=datos;host=dbpets;port=3306", 'root', 'admin', { RaiseError => 1, AutoCommit => 1 })
  or die encode_json({ error => "Error al conectar a la base de datos: " . DBI->errstr });

# Consulta SQL para obtener los datos
my $sql = 'SELECT * from productos';
my $sth = $dbh->prepare($sql)
  or die encode_json({ error => "Error al preparar la consulta: " . $dbh->errstr });

# Ejecutar la consulta
eval {
    $sth->execute()
      or die "Error al ejecutar la consulta: " . $sth->errstr;
};

if ($@) {
    print encode_json({ error => "Error durante la consulta: $@" });
} else {
    my @productos;  # Array para los registros
    while (my $row = $sth->fetchrow_hashref) {
        push @productos, {
            id     => $row->{id},
            nombre => $row->{nombre},
            tipo   => $row->{tipo},
            precio => $row->{precio},
            url => $row->{url},
        };
    }

    # Convertir el array de productos a JSON y enviarlo como respuesta
    print encode_json({
        mensaje => "Datos leídos exitosamente",
        data    => \@productos,
    });
}

# Finalizar la declaración y desconectar
$sth->finish();
$dbh->disconnect();

