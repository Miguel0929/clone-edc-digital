var tour = new Tour({
  name: "tour",
  steps: [
    {
      element: "#tour-5",
      title: "Título 5",
      content: "Las cosas son muy diferentes de entonces, las cosas eran más significativas.",
      placement: "bottom"
    },
    {
      element: "#tour-6",
      title: "Título 6",
      content: "Las cosas son muy diferentes de entonces, las cosas eran más significativas.",
      placement: "top"
    },
    {
      element: "#tour-7",
      title: "Título 7",
      content: "Pero las cosas cambian y tenemos dos opciones: cambiar o cambiarlas.",
      placement: "top"
    }
  ],
  container: "body",
  smartPlacement: true,
  keyboard: true,
  storage: window.localStorage,
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
  onEnd: function (tour) {console.log("Ended tour")},
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

//console.log(tour._options.steps[1].element);
  