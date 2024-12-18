#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use CGI::Session;

# Crear el objeto CGI
my $cgi = CGI->new();

# Crear una nueva sesión o recuperar la sesión existente
my $session = CGI::Session->load("driver:File", $cgi->cookie('SESSION_ID') || undef , {Directory => '/usr/local/apache2/cgi-bin/controller/tmp'});

# Verificar si el parámetro 'logout' fue enviado (botón de cerrar sesión)
#

if (!$session || !$session->param('_EMAIL')) {
    # Si la sesión ha expirado o está vacía, destruirla y redirigir al login
    print $cgi->redirect(-uri => '/cgi-bin/view/public/login.perl');
    exit;
}

if ($session->is_expired || $session->is_empty) {
    # Si la sesión ha expirado o está vacía, destruirla y redirigir al login
    $session->delete();
    $session->flush();
    print $cgi->redirect(-uri => '/cgi-bin/view/public/login.perl');
    exit;
}


if ($cgi->param('logout')) {
    # Borrar la sesión y redirigir a la página principal
    $session->delete();
    $session->flush();
    my $cookie = $cgi->cookie(-name => 'SESSION_ID', -value => '', -expires => '-1d');
    print $cgi->redirect(-uri => '/cgi-bin/view/public/login.perl', -cookie => $cookie);
    exit;
}

# Verificar si el parámetro '_EMAIL' está presente en la sesión
if ($session->param('_EMAIL')) {
    # Si el usuario está logueado, mostrar la tienda con el correo en el header
    my $email = $session->param('_EMAIL');
    print $cgi->header('text/html');
    print <<HTML;
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tienda</title>
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>
</head>
<body>
    <nav class="navbar navbar-inverse">
        <div class="container-fluid">
            <div class="navbar-header">
                <a class="navbar-brand" href="#">Mi Tienda</a>
            </div>
	    <ul class="nav navbar-nav">
                <li><a href="quienes-somos.perl">Quienes somos?</a></li>
                <li><a href="productos.perl">Productos</a></li>
                <li><a href="tienda.perl">Tienda</a></li>
                <li><a href="compras.perl">Compras</a></li>
            </ul>
            <ul class="nav navbar-nav navbar-right">
                <li><a href="#"><span class="glyphicon glyphicon-user"></span> $email</a></li>
                <li>
                    <form method="post" style="display:inline;">
                        <button type="submit" name="logout" class="btn btn-link navbar-btn">Cerrar sesion</button>
                    </form>
                </li>
            </ul>
        </div>
    </nav>
    <div class="container">
        <h1>Bienvenido a la tienda</h1>

        <div class="row" id="table-container">
            <!-- Aquí se insertará la tabla dinámicamente -->
        </div>
    </div>
    <script>
		\$(document).ready(function() {
			function cargarTabla() {
				\$.ajax({
					url: "/cgi-bin/controller/productos/read.perl", // Archivo Perl que devuelve los registros en formato JSON
					type: "GET",
					dataType: "json"
				})
				.done(function(dataset) {
					// Generar tabla dinámica
					let table = "";
					console.log(dataset.data);
					dataset.data.forEach(function(record) {
            					table += "<div class='col-sm-4'><div class='thumbnail'>"
                    				table += "<img src='"+record.url+ "' alt='Producto 3'  height='250'>"
                        			table += "<h3>"+record.nombre+"</h3>"
                        			table += "<p>precio "+record.precio+"</p>"
                        			table += "<p>tipo: "+record.tipo+"</p>"
                        			table += "<p><a href='#' class='btn btn-primary comprarBtn' role='button' data-id='" + record.id + "'>Comprar</a></p>"
            					table += "</div></div>"
					});

					// Insertar la tabla en el contenedor
					\$("#table-container").html(table);
					\$(".comprarBtn").on('click', function() {
						let id = \$(this).data('id');


					var dt = {
						email: '$email',
						producto_id: id,
					};
					var request = \$.ajax({
						url: "/cgi-bin/controller/compras/create.perl",
						type: "POST",
						data: dt,
						dataType: "json"
					});
					request.done(function(dataset) {
						\$('#respAjax').addClass("well");
						\$('#respAjax').html("Datos enviados correctamente: " + JSON.stringify(dataset));
						cargarTabla();
					});
					request.fail(function(jqXHR, textStatus) {
						alert("Error en la solicitud: " + textStatus);
					});



					});
					\$(".deleteBtn").on('click', function() {
						let id = \$(this).data('id');
						eliminarMascota(id);
					});
				})
				.fail(function(jqXHR, textStatus) {
					\$("#table-container").html("<div class='alert alert-danger'>Error al cargar los datos: " + textStatus + "</div>");
				});
			}

			cargarTabla();
			})
    </script>
</body>
</html>
HTML
} else {
    # Si el usuario no está logueado, mostrar mensaje de no logueado
    print $cgi->header('text/html');
    print <<HTML;
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>No logueado</title>
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
</head>
<body>
    <div class="container">
        <h1>No estás logueado</h1>
        <p><a href="login.pl" class="btn btn-primary">Iniciar sesión</a></p>
    </div>
</body>
</html>
HTML
}