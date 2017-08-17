
var tour = new Tour({
  name: "tour",
  steps: [
    {
      element: "#tour-1",
      title: "Título 1",
      content: "Las cosas son muy diferentes de entonces, las cosas eran más significativas.",
      placement: "bottom"
    },
    {
      element: "#tour-2",
      title: "Título 2",
      content: "Las cosas son muy diferentes de entonces, las cosas eran más significativas."
    },
    {
      element: "#tour-3",
      title: "Título 3",
      content: "Pero las cosas cambian y tenemos dos opciones: cambiar o cambiarlas.",
      placement: "bottom"
    },
     {
      element: "#tour-4",
      title: "Título 4",
      content: "Pero las cosas cambian y tenemos dos opciones: cambiar o cambiarlas.",
      placement: "bottom"
    }
  ],
  container: "body",
  smartPlacement: true,
  keyboard: true,
  storage: window.localStorage,
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
tour.init();

// Start the tour
tour.start(true);

//tour.restart();

