$(document).on('turbolinks:load', function(){
  $('.sortable3').sortable({
    axis: 'y',
    placeholder: "sortable-placeholder",
    handle: '.handle-sort',
    update: function(){
      $.post($(this).data('update-url'), $(this).sortable('serialize'));
      $("#alert-sortable").css('display','block');
      setTimeout(function(){$("#alert-sortable").css('display','none');},3000);               
    }
  });
});