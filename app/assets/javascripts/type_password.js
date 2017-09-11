function closeSwal() {
  swal.close();
};

sweetAlert({
  html: true,
  title: "¡Ups!<small><a href='JavaScript:void(0)' style='position: relative; top:-43px; right:-178px;' onclick='closeSwal()' class='swal-close'><i class='fa fa-times'></i></a></small>",
  text: "Olvidaste escribir tu contraseña actual o escribiste una incorrecta. Intenta de nuevo por favor:",
  type: "input",
  showCancelButton: false,
  closeOnConfirm: false,
  confirmButtonText: "Enviar",
  animation: "slide-from-top",
  inputPlaceholder: "Contraseña"
},
function(inputValue){
  document.getElementById("user_current_password").value = inputValue;
  document.getElementById("form-work").submit();
  console.log("comfirm");
});

$( "div.sweet-alert" ).find( "input" ).attr( "type", "password" );