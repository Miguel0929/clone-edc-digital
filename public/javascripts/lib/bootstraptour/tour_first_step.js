var tour = new Tour({
  name: "tour",
  steps: [
    {
      element: "#tour-1",
      title: "Menú superior",
      content: "Aquí encontrarás tres elementos de rápido acceso: notificaciones de la plataforma de EDC Digital, mensajes intercambiados con tus mentores y, por último, un enlace para ver preguntas frecuentes. A la derecha, tu foto de perfil te permite entrar a configuraciones y a tu información de perfil.",
      placement: "bottom"
    },
    {
      element: "#tour-2",
      title: "Menú lateral",
      content: "Éste es el menú principal. A través de él puedes navegar por las diferentes secciones de la plataforma. En la sección de 'Mapa del sitio' podrás leer los detalles del resto de ellas para conocer su contenido."
    },
    {
      element: "#tour-3",
      title: "Título de página",
      content: "Todas las secciones de la plataforma tienen un título, mismo que contiene información sobre la ubicación y contenido de la página. En algunos verás botones para realizar ciertas acciones. ¡Explóralos!",
      placement: "bottom"
    },
     {
      element: "#tour-4",
      title: "Tarjeta de programa",
      content: "Las tarjetas de programa indican los cursos (programas) que te han sido habilitados. Además del nombre, muestran información importante como tus porcentajes de avance y un enlace para continuar si el curso ya ha sido iniciado.",
      placement: "bottom"
    }
  ],
  container: "body",
  smartPlacement: true,
  keyboard: true,
  storage: false,
  debug: true,
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
        'position': 1
      },
      success: function(data) {
        console.log("Cambio exitoso en la posición " + data["position"] + " del hash 'tour_trigger'");
        location.reload();
      },
      error: function(data) {
        console.log("Hubo un error en el cambio en la posición " + data["position"] + " del hash 'tour_trigger'");
      }
    });
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
tour.init();

// Start the tour
tour.start(true);

//tour.restart();

