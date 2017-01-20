
$(document).on('turbolinks:load', function(){
  setTimeout(function(){
    $('.dimiss').alert('close');
  }, 3000);
});
