$(document).on('turbolinks:load', function(){
  $('.sortable2').sortable({
    axis: 'y',
    placeholder: "sortable-placeholder",
    handle: '.handle-sort',
    update: function(){
      $.post($(this).data('update-url'), $(this).sortable('serialize'));
      $("#alert-ra").css('display','block');
      setTimeout(function(){$("#alert-ra").css('display','none');},3000);               
    }
  });
});