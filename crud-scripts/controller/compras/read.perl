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
my $dbh = DBI->connect("DBI:MariaDB:database=datos;host=dbpets;port=3306", 'root', 'admin', { RaiseError => 1, AutoCommit => 1 })
  or die to_json({ error => "Error al conectar a la base de datos: " . DBI->errstr });

# Consulta SQL para insertar los datos
my $sql = 'SELECT compras.id, productos.nombre, productos.tipo, productos.precio, productos.url from compras JOIN productos ON compras.producto_id = productos.id';
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

  my @productos;  # Array para los registros
my $suma_precio = 0;
while (my $row = $sth->fetchrow_hashref) {
    push @productos, {
        id     => $row->{id},
        nombre     => $row->{nombre},
        tipo => $row->{tipo},
        precio  => $row->{precio},
        url  => $row->{url},
};
$suma_precio += $row->{precio};
}

# Convertir el array a JSON
my $json = encode_json(\@productos);
    # Respuesta JSON de éxito
    print to_json({
        mensaje => "Datos leidos exitosamente",
        data    => \@productos,
	suma    => $suma_precio,
    });

}

# Finalizar la declaración y desconectar
$sth->finish();
$dbh->disconnect();
