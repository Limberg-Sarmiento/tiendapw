#!/usr/bin/perl
use strict;
use warnings;

# Imprimir cabecera HTTP válida
print "Content-type: text/html\n\n";

print <<EOF;
<!DOCTYPE html>
<html lang="es">
<head>
    <title>Formulario de Mascotas</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>
</head>
<body>
    <div class="container">
        <h2>Formulario de Registro de Mascotas</h2>
        <form action="myscript.perl">
            <div class="form-group">
                <label for="name">Nombre:</label>
                <input type="text" class="form-control" id="name" placeholder="Ingrese el nombre de la mascota" name="name">
            </div>
            <div class="form-group">
                <label for="owner">Propietario:</label>
                <input type="text" class="form-control" id="owner" placeholder="Ingrese el nombre del propietario" name="owner">
            </div>
            <div class="form-group">
                <label for="species">Especie:</label>
                <input type="text" class="form-control" id="species" placeholder="Ingrese la especie (perro, gato, etc.)" name="species">
            </div>
            <div class="form-group">
                <label for="sex">Sexo:</label>
                <input type="text" class="form-control" id="sex" placeholder="Ingrese el sexo (macho/hembra)" name="sex">
            </div>
            <div class="form-group">
                <label for="birth">Nacimiento:</label>
                <input type="date" class="form-control" id="birth" name="birth">
            </div>
            <div class="form-group">
                <label for="death">Fallecimiento:</label>
                <input type="date" class="form-control" id="death" name="death">
            </div>
            <div class="form-group">
                <div id="respAjax" class=""></div>
            </div>
            <button id="submitAJAX" class="btn_submit btn btn-default">Registrar</button>
        </form>
        <h3>Lista de Mascotas Registradas</h3>
        <div id="table-container">
            <!-- Aquí se insertará la tabla dinámicamente -->
        </div>
        <div id="editModal" class="modal fade" role="dialog">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <button type="button" class="close" data-dismiss="modal">&times;</button>
                        <h4 class="modal-title">Editar Mascota</h4>
                    </div>
                    <div class="modal-body">
                        <form id="editForm">
                            <div class="form-group">
                                <label for="editName">Nombre:</label>
                                <input type="text" class="form-control" id="editName" name="name">
                            </div>
                            <div class="form-group">
                                <label for="editOwner">Propietario:</label>
                                <input type="text" class="form-control" id="editOwner" name="owner">
                            </div>
                            <div class="form-group">
                                <label for="editSpecies">Especie:</label>
                                <input type="text" class="form-control" id="editSpecies" name="species">
                            </div>
                            <div class="form-group">
                                <label for="editSex">Sexo:</label>
                                <input type="text" class="form-control" id="editSex" name="sex">
                            </div>
                            <div class="form-group">
                                <label for="editBirth">Nacimiento:</label>
                                <input type="date" class="form-control" id="editBirth" name="birth">
                            </div>
                            <div class="form-group">
                                <label for="editDeath">Fallecimiento:</label>
                                <input type="date" class="form-control" id="editDeath" name="death">
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
					url: "read.perl", // Archivo Perl que devuelve los registros en formato JSON
					type: "GET",
					dataType: "json"
				})
				.done(function(dataset) {
					// Generar tabla dinámica
					let table = "<table class='table table-bordered'><thead><tr><th>ID</th><th>Nombre</th><th>Propietario</th><th>Especie</th><th>Sexo</th><th>Nacimiento</th><th>Fallecimiento</th></tr></thead><tbody>";
					console.log(dataset.data);
					dataset.data.forEach(function(record) {
						console.log(record.id);
						table += "<tr>";
						table += "<td>"+record.id+"</td>";
						table += "<td>"+record.name+"</td>";
						table += "<td>"+record.owner+"</td>";
						table += "<td>"+record.species+"</td>";
						table += "<td>"+record.sex+"</td>";
						table += "<td>"+record.birth+"</td>";
						table += "<td>"+record.death+"</td>";
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
						let name = \$(this).data('name');
						console.log(name);

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
						name: \$("#name").val(),
						owner: \$("#owner").val(),
						species: \$("#species").val(),
						sex: \$("#sex").val(),
						birth: \$("#birth").val(),
						death: \$("#death").val()
					};
					var request = \$.ajax({
						url: "create.perl",
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
					name: \$('#editName').val(),
					owner: \$('#editOwner').val(),
					species: \$('#editSpecies').val(),
					sex: \$('#editSex').val(),
					birth: \$('#editBirth').val(),
					death: \$('#editDeath').val()
				};

				// Enviar la solicitud AJAX para actualizar los datos
				\$.ajax({
					url: "update.perl", // Archivo Perl que actualiza la mascota en la base de datos
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
						url: "delete.perl", // El archivo Perl para eliminar un registro
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
					url: "findbyid.perl", // Un script que devolverá los datos de la mascota en formato JSON
					type: "GET",
					data: { id: id },
					dataType: "json",
					success: function(data) {
						if (data.error) {
							alert("Error: " + data.error);
						} else {
							// Rellenar los campos del modal con los datos de la mascota
							\$('#editName').val(data.name);
							\$('#editOwner').val(data.owner);
							\$('#editSpecies').val(data.species);
							\$('#editSex').val(data.sex);
							\$('#editBirth').val(data.birth);
							\$('#editDeath').val(data.death);
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