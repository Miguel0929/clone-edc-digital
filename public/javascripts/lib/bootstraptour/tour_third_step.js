var tour3 = new Tour({
  name: "tour3",
  steps: [
    {
      element: "#tour-8",
      title: "Calificación de contenido",
      content: "Para nosotros es muy importante tu retroalimentación sobre el contenido de EDC-digital, por lo tanto tu calificación de las lecciones siempre son bienvenidas y te agradecemos mucho por tomarte el tiempo :)",
      placement: "bottom"
    },
    {
      element: "#tour-9",
      title: "Contenido de la lección",
      content: "Aquí verás el contenido de cada lección. Algunas veces verás videos, y otras veces podrás leer textos e infográficos. Independientemente de su formato, está diseñado para transmitirte el conocimiento de la mejor manera.",
      placement: "top"
    },
    {
      element: "#tour-10",
      title: "Barra de navegación",
      content: "Esta barra te permitirá navegar a través del contenido de cada módulo de manera consecutiva. También puedes reportar el contenido en caso de que experimentes alguna falla en tu exploración usando el botón rojo con la bandera.",
      placement: "top",
      backdrop: true,
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
        'position': 3
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
tour3.init();

// Start the tour
tour3.start(true);

//tour.restart();
 
