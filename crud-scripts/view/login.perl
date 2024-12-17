#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use DBI;
use JSON;

# Crear objeto CGI
my $cgi = CGI->new();

# Obtener parámetros si se envían (para la validación del login)
my $email      = $cgi->param('email');
my $contrasena = $cgi->param('contrasena');

# Imprimir cabecera HTTP
print $cgi->header('text/html; charset=UTF-8');

# Verificar si los parámetros se enviaron (proceso de validación)
if ($email && $contrasena) {
    # Conectar a la base de datos
    my $dsn = "DBI:MariaDB:database=datos;host=localhost;port=3306";
    my $user = "root";
    my $password = "admin";

    my $dbh = DBI->connect($dsn, $user, $password, { RaiseError => 1, AutoCommit => 1 });

    # Consulta SQL para validar el usuario
    my $sql = 'SELECT * FROM usuarios WHERE email = ? AND contrasena = ?';
    my $sth = $dbh->prepare($sql);
    $sth->execute($email, $contrasena);

    if (my $row = $sth->fetchrow_hashref()) {
        print "<script>alert('Inicio de sesión exitoso. ¡Bienvenido $row->{nombre}!'); window.location.href = 'bienvenido.html';</script>";
    } else {
        print "<script>alert('Correo o contraseña incorrectos. Inténtalo de nuevo.');</script>";
    }

    # Finalizar
    $sth->finish();
    $dbh->disconnect();
}

# Mostrar el formulario de inicio de sesión
print <<'EOF';
<!DOCTYPE html>
<html lang="es">
<head>
    <title>Iniciar Sesión</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>
</head>
<body>
    <div class="container">
        <h2>Iniciar Sesión</h2>
        
            <div class="form-group">
                <label for="email">Correo Electrónico:</label>
                <input type="email" class="form-control" id="email" name="email" placeholder="Ingrese su correo" required>
            </div>
            <div class="form-group">
                <label for="contrasena">Contraseña:</label>
                <input type="password" class="form-control" id="contrasena" name="contrasena" placeholder="Ingrese su contraseña" required>
            </div>
            <button class="btn btn-primary btn_login">Iniciar Sesión</button>
        <p>¿No tienes cuenta? <a href="registro.perl">Regístrate aquí</a></p>
    </div>
	<script>
		$(document).ready(function() {
			$('.btn_login').on('click', function(e) {
				var objectEvent = $(this);
				e.preventDefault();
					var dt = {
						email: $("#email").val(),
						contrasena: $("#contrasena").val(),
					};
					console.log(dt);
					var request = $.ajax({
						url: "/cgi-bin/controller/login/auth.perl",
						type: "POST",
						data: dt,
						dataType: "json"
					});
					request.done(function(dataset) {
						console.log(dataset);
                        window.location.href = "/cgi-bin/view/test.perl  ";
					});
					request.fail(function(jqXHR, textStatus) {
						alert("Error en la solicitud: " + textStatus);
					});
			});
		});
	</script>
</body>

</html>
EOF

