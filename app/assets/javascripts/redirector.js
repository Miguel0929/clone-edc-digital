$(document).on('turbolinks:load', function(){
  $('.redirector').click(function(e){
    e.preventDefault();
    window.location = $(this).attr('href');
  });
});
