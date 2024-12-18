#!/usr/bin/perl
use strict;
use warnings;

# Imprimir cabecera HTTP válida
print "Content-type: text/html\n\n";

print <<EOF;
<!DOCTYPE html>
<html lang="es">
<head>
    <title>Formulario de Registro</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>
</head>
<body>
    <div class="container">
        <h2>Formulario de Registro</h2>
        <form id="formRegistro">
            <div class="form-group">
                <label for="nombre">Nombre:</label>
                <input type="text" class="form-control" id="nombre" name="nombre" placeholder="Ingrese su nombre" required>
            </div>
            <div class="form-group">
                <label for="email">Correo Electrónico:</label>
                <input type="email" class="form-control" id="email" name="email" placeholder="Ingrese su correo" required>
            </div>
            <div class="form-group">
                <label for="contrasena">Contraseña:</label>
                <input type="password" class="form-control" id="contrasena" name="contrasena" placeholder="Ingrese su contraseña" required>
            </div>
            <div class="form-group">
                <div id="respuesta" class="alert" style="display:none;"></div>
            </div>
            <button type="submit" class="btn btn-primary">Registrar</button>
        </form>
    </div>

    <script>
        \$(document).ready(function () {
            \$("#formRegistro").on("submit", function (event) {
                event.preventDefault(); // Prevenir el comportamiento predeterminado del formulario

                // Recoger los datos del formulario
                const datos = {
                    nombre: \$("#nombre").val(),
                    email: \$("#email").val(),
                    contrasena: \$("#contrasena").val(),
                };

                // Enviar los datos al archivo create.perl usando AJAX
                \$.ajax({
                    url: "/cgi-bin/controller/login/create.perl",
                    type: "POST",
                    data: datos,
                    dataType: "json",
                   success: function (respuesta) {
                   if (respuesta.exito) {  // Verifica el campo 'exito'
                  \$("#respuesta")
                   .removeClass("alert-danger")
                     .addClass("alert-success")
                    .text(respuesta.mensaje)  // Usa el mensaje de éxito
                    .show();
                    } else {
                   \$("#respuesta")
                   .removeClass("alert-success")
                    .addClass("alert-danger")
                    .text("Error: " + respuesta.mensaje)  // Si 'exito' es false, muestra el error
                    .show();
                      }
                  },
                    error: function () {
                        \$("#respuesta")
                            .removeClass("alert-success")
                            .addClass("alert-danger")
                            .text("Error al registrar los datos.")
                            .show();
                    },
                });
            });
        });
    </script>
</body>
</html>
EOF
