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


my $email = $session->param('_EMAIL');
# Imprimir cabecera HTTP válida
print "Content-type: text/html\n\n";

print <<EOF;
<!DOCTYPE html>
<html lang="es">
<head>
    <title>Formulario de Productos</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
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
        <h2>Formulario de Registro de Productos</h2>
        <form action="myscript.perl">
            <div class="form-group">
                <label for="nombre">Nombre:</label>
                <input type="text" class="form-control" id="nombre" placeholder="Ingrese el nombre de la mascota" name="nombre">
            </div>
            <div class="form-group">
                <label for="precio">Precio:</label>
                <input type="text" class="form-control" id="precio" placeholder="Ingrese el nombre del propietario" name="precio">
            </div>
            <div class="form-group">
                <label for="tipo">Tipo:</label>
                <input type="text" class="form-control" id="tipo" placeholder="Ingrese tipo" name="tipo">
            </div>
            <div class="form-group">
                <label for="url">Url:</label>
                <input type="text" class="form-control" id="url" placeholder="Ingrese url" name="url">
            </div>
            <div class="form-group">
                <div id="respAjax" class=""></div>
            </div>
            <button id="submitAJAX" class="btn_submit btn btn-default">Registrar</button>
        </form>
        <h3>Lista de Productos Registradas</h3>
        <div id="table-container">
            <!-- Aquí se insertará la tabla dinámicamente -->
        </div>
        <div id="editModal" class="modal fade" role="dialog">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <button type="button" class="close" data-dismiss="modal">&times;</button>
                        <h4 class="modal-title">Editar Producto</h4>
                    </div>
                    <div class="modal-body">
                        <form id="editForm">
                            <div class="form-group">
                                <label for="editNombre">Nombre:</label>
                                <input type="text" class="form-control" id="editNombre" name="nombre">
                            </div>
                            <div class="form-group">
                                <label for="editPrecio">Precio:</label>
                                <input type="text" class="form-control" id="editPrecio" name="precio">
                            </div>
                            <div class="form-group">
                                <label for="editTipo">Tipo:</label>
                                <input type="text" class="form-control" id="editTipo" name="tipo">
                            </div>
                            <div class="form-group">
                                <label for="editUrl">Url:</label>
                                <input type="text" class="form-control" id="editUrl" name="url">
                            </div>
                            <button type="submit" class="btn btn-primary">Guardar Cambios</button>
                        </form>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-default" data-dismiss="modal">Cerrar</button>
                    </div>
                </div>
            </div>
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
					let table = "<table class='table table-bordered'><thead><tr><th>ID</th><th>Nombre</th><th>Precio</th><th>Url</th><th>Tipo</th><th>Acciones</th></tr></thead><tbody>";
					console.log(dataset.data);
					dataset.data.forEach(function(record) {
						console.log(record.id);
						table += "<tr>";
						table += "<td>"+record.id+"</td>";
						table += "<td>"+record.nombre+"</td>";
						table += "<td>"+record.precio+"</td>";
						table += "<td>"+record.tipo+"</td>";
						table += "<td>"+record.url+"</td>";
						table += "<td><button class='btn btn-info btn-sm editBtn' data-id='" + record.id + "'>Editar</button>";
						table += " <button class='btn btn-danger btn-sm deleteBtn' data-id='" + record.id + "'>Eliminar</button></td>";
						table += "</tr>";
					});
					table += "</tbody></table>";

					// Insertar la tabla en el contenedor
					\$("#table-container").html(table);
					\$(".editBtn").on('click', function() {
						console.log("hola");
						let id = \$(this).data('id');
						let nombre = \$(this).data('nombre');
						console.log(nombre);

						editarMascota(id);
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

			// Crear
			\$('.btn_submit').on('click', function(e) {
				var objectEvent = \$(this);
				if (objectEvent.attr('id') === 'submitNoAJAX') {
					\$('form').attr('action', 'myscript.perl');
					return true;
				}
				e.preventDefault();
				if (objectEvent.attr('id') === 'submitAJAX') {
					var dt = {
						nombre: \$("#nombre").val(),
						precio: \$("#precio").val(),
						tipo: \$("#tipo").val(),
						url: \$("#url").val(),
					};
					var request = \$.ajax({
						url: "/cgi-bin/controller/productos/create.perl",
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
				}
			});

			// actualizar
			\$('#editForm').on('submit', function(e) {
				e.preventDefault(); // Evitar el comportamiento por defecto del formulario

				// Recoger los datos del formulario
				var formData = {
					id: \$('#editForm').data('id'), // Obtener el id de la mascota a editar
					nombre: \$('#editNombre').val(),
					precio: \$('#editPrecio').val(),
					tipo: \$('#editTipo').val(),
					url: \$('#editUrl').val(),
				};

				// Enviar la solicitud AJAX para actualizar los datos
				\$.ajax({
					url: "/cgi-bin/controller/productos/update.perl", // Archivo Perl que actualiza la mascota en la base de datos
					type: "POST",
					data: formData,
					dataType: "json",
					success: function(response) {
						if (response.error) {
							alert("Error: " + response.error);
						} else {
							// Cerrar el modal y recargar la tabla
							\$('#editModal').modal('hide');
							cargarTabla();
						}
					},
					error: function(jqXHR, textStatus) {
						alert("Error en la solicitud: " + textStatus);
					}
				});
			});

			// eliminar
			function eliminarMascota(id) {
				console.log("id", id);
				if (confirm("¿Estás seguro de que deseas eliminar esta mascota?")) {
					var request = \$.ajax({
						url: "/cgi-bin/controller/productos/delete.perl", // El archivo Perl para eliminar un registro
						type: "POST",
						data: { id: id },
						dataType: "json",
					});
					request.done(function() {
						\$('#respAjax').addClass("well");
						\$('#respAjax').html("Dato eliminado");
						cargarTabla();
					});
					request.fail(function(jqXHR, textStatus) {
						alert("Error en la solicitud: " + textStatus);
					});
				}
			}

			// abrir modal
			function editarMascota(id) {
				// Hacer una solicitud para obtener los datos de la mascota
				\$.ajax({
					url: "/cgi-bin/controller/productos/findbyid.perl", // Un script que devolverá los datos de la mascota en formato JSON
					type: "GET",
					data: { id: id },
					dataType: "json",
					success: function(data) {
						if (data.error) {
							alert("Error: " + data.error);
						} else {
							// Rellenar los campos del modal con los datos de la mascota
							\$('#editNombre').val(data.nombre);
							\$('#editPrecio').val(data.precio);
							\$('#editTipo').val(data.tipo);
							\$('#editUrl').val(data.url);
							\$('#editForm').data('id', id); // Guardar el id en el formulario

							// Mostrar el modal
							\$('#editModal').modal('show');
						}
					},
					error: function(jqXHR, textStatus) {
						alert("Error al obtener los datos: " + textStatus);
					}
				});
			}

			
		});
	</script>
</body>
</html>

EOF
