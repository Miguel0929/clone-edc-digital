var tour4 = new Tour({
  name: "tour4",
  steps: [
    {
      element: "#tour-11",
      title: "Título del módulo",
      content: "Una vez dentro del contenido podrás ver el módulo en el que te encuentras para que nunca pierdas de vista tu ubicación.",
      placement: "right"
    },
    {
      element: "#tour-12",
      title: "Pregunta",
      content: "Siempre podrás regresar a ver tus respuestas una vez que hayas contestado una pregunta. En caso de que quieras editarla, puedes utilizar el botón de 'Editar respuesta' en la barra de navegación.",
      placement: "top"
    },
    {
      element: "#tour-10",
      title: "Barra de navegación",
      content: "Esta barra te permitirá navegar a través del contenido de cada módulo de manera consecutiva y editar las respuestas de tus preguntas. También puedes reportar el contenido en caso de que experimentes alguna falla en tu exploración usando el botón rodo de la bandera.",
      placement: "top",
      backdrop: true
    },
    {
      element: "#btnToggleSlideUpSize",
      title: "Enviar dudas o comentarios",
      content: "Utiliza este botón siempre que necesites aclarar algo sobre una pregunta o bien hacer un comentario. Tu mensaje llegará directamente a tus mentores y ellos atenderán tu petición.",
      placement: "top",
      backdrop: true
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
        'position': 4
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
tour4.init();

// Start the tour
tour4.start(true);

//tour.restart();

  