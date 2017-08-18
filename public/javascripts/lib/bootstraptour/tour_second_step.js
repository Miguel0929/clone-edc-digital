var tour2 = new Tour({
  name: "tour2",
  steps: [
    {
      element: "#tour-5",
      title: "Título del programa",
      content: "Como su nombre lo sugiere, este panel te mostrará el título del programa y una descripción del contenido. Sin embargo, también te muestra tus porcentajes de avances y, en caso de haber sido evaluado, te permitirá ver los detalles de tu evaluación. ¡Mantente atento a esta información!",
      placement: "bottom"
    },
    {
      element: "#tour-6",
      title: "Detalles del contenido",
      content: "Aquí se enlistan todos los módulos de los que está compuesto cada programa. Puedes ver su nombre y la información de tu progreso. Cada uno está dentro de un panel colapsable, un click hará que despliegue su contenido. ",
      placement: "top"
    },
    {
      element: "#tour-7",
      title: "Páneles de módulos",
      content: "Una vez abierto al hacer click, verás todo el contenido del módulo. Este contenido se compone de lecciones y preguntas. Las etiquetas de la derecha te permitirán visualizar si ya has visitado cada contenido, y en el caso de las preguntas, si ya han sido contestadas. ¡Pruébalas!",
      placement: "top"
    }
  ],
  container: "body",
  smartPlacement: true,
  keyboard: true,
  storage: false,
  debug: false,
  backdrop: false,
  backdropContainer: 'body',
  backdropPadding: 0,
  redirect: true,
  orphan: false,
  duration: false,
  delay: false,
  basePath: "",
  template: "<div class='popover tour'><div class='arrow'></div><h3 class='popover-title'></h3><div class='popover-content'></div><div class='popover-navigation'><button class='btn btn-info btn-sm pull-left' data-role='end'>Terminar</button><div class='btn-group pull-right'><button class='btn btn-complete btn-sm' data-role='prev'>« Anterior</button><button class='btn btn-complete btn-sm' data-role='next'>Siguiente »</button></div></div></div>",
  afterGetState: function (key, value) {},
  afterSetState: function (key, value) {},
  afterRemoveState: function (key, value) {},
  onStart: function (tour) {},
  onEnd: function (tour) {
    $.ajax({
      type: "post", url: "/dashboard/change_tour_trigger",
      data: {
        'position': 2
      },
      success: function(data) {
        console.log("Cambio exitoso en la posición " + data["position"] + " del hash 'tour_trigger'");
        location.reload();
      },
      error: function(data) {
        console.log("Hubo un error en el cambio en la posición " + data["position"] + " del hash 'tour_trigger'");
      }
    });
    console.log("Ended tour");
  },
  onShow: function (tour) {},
  onShown: function (tour) {},
  onHide: function (tour) {},
  onHidden: function (tour) {},
  onNext: function (tour) {},
  onPrev: function (tour) {},
  onPause: function (tour, duration) {},
  onResume: function (tour, duration) {},
  onRedirectError: function (tour) {}
});

// Initialize the tour
tour2.init();

// Start the tour
tour2.start(true);

//tour.restart();

  