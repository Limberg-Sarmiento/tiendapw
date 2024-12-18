#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use DBI;
use JSON;

use CGI::Session;

# Crear objeto CGI
my $cgi = CGI->new();

# Crear una nueva sesión o recuperar la existente
my $session = CGI::Session->load("driver:File", $cgi->cookie('SESSION_ID') || undef, {Directory => '/usr/local/apache2/cgi-bin/controller/tmp'});

# Verificar si la sesión es válida y contiene información de inicio de sesión
if ($session && $session->param('_EMAIL')) {
    # Si el usuario ya está logueado, redirigir a tienda.pl
    print $cgi->redirect(-uri => '/cgi-bin/view/private/tienda.perl');
    exit;
}

# Obtener parámetros si se envían (para la validación del login)
my $email      = $cgi->param('email');
my $contrasena = $cgi->param('contrasena');

# Imprimir cabecera HTTP
print $cgi->header('text/html; charset=UTF-8');

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
        <p>¿No tienes cuenta? <a href="/cgi-bin/view/public/registro.perl">Regístrate aquí</a></p>
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
                        window.location.href = "/cgi-bin/view/private/tienda.perl";
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
