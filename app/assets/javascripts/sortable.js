$(document).on('turbolinks:load', function(){
  $('.sortable').sortable({
    axis: 'y',
    placeholder: "sortable-placeholder",
    handle: '.handle-sort',
    update: function(){
      debugger
      $.post($(this).data('update-url'), $(this).sortable('serialize'));
    }
  });
});
