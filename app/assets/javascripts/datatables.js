$(document).on('turbolinks:load', function(){
  $('.datatable').each(function(){
    if(!$(this).hasClass('dataTable')){
      var responsiveHelper = undefined;
      var breakpointDefinition = {
          tablet: 1024,
          phone: 480
      };

      var table = $(this);

      var settings = {
          pageLength: 30,
          "sDom": "<'table-responsive't><'row'<p i>>",
          "destroy": true,
          "scrollCollapse": true,
          "iDisplayLength": 5,
          language: {
            "sProcessing":     "Procesando...",
            "sLengthMenu":     "Mostrar _MENU_ registros",
            "sZeroRecords":    "No se encontraron resultados",
            "sEmptyTable":     "Ningún dato disponible en esta tabla",
            "sInfo":           "Mostrando registros del _START_ al _END_ de un total de _TOTAL_ registros",
            "sInfoEmpty":      "Mostrando registros del 0 al 0 de un total de 0 registros",
            "sInfoFiltered":   "(filtrado de un total de _MAX_ registros)",
            "sInfoPostFix":    "",
            "sSearch":         "Buscar:",
            "sUrl":            "",
            "sInfoThousands":  ",",
            "sLoadingRecords": "Cargando...",
            "oPaginate": {
                "sFirst":    "Primero",
                "sLast":     "Último",
                "sNext":     "Siguiente",
                "sPrevious": "Anterior"
            },
            "oAria": {
                "sSortAscending":  ": Activar para ordenar la columna de manera ascendente",
                "sSortDescending": ": Activar para ordenar la columna de manera descendente"
            }
          }
      };

      if(table.hasClass('show_group_students')){settings.pageLength = 100};

      table.dataTable(settings);

      $('#search-table').keyup(function() {
          table.fnFilter($(this).val());
      });
    }

  });
});
