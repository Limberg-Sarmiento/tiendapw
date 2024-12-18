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
    print $cgi->header(
	    -type => 'text/html; charset=UTF-8', 
	    -charset => 'UTF-8'
    );
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
	<h2>¿Quienes somos?</h2>
        <p>Bienvenidos a <strong>Tienda Virtual</strong>, una empresa dedicada a ofrecer los mejores productos para ti. Nuestra misión es proporcionarte una experiencia de compra única con productos de calidad y un servicio al cliente excepcional. Contamos con una amplia variedad de artículos, desde tecnología hasta artículos para el hogar, todos disponibles para su compra online.</p>
        <p>En Tienda Virtual, nos apasiona brindarte lo mejor. Nos esforzamos por ofrecerte productos innovadores, precios competitivos y un proceso de compra fácil y seguro. ¡Explora nuestras opciones y encuentra lo que más te gusta!</p>
    </div>
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
