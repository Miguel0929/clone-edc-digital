$(document).on('turbolinks:load', function(){
  $('.sortable').sortable({
    axis: 'y',
    placeholder: "sortable-placeholder",
    handle: '.handle-sort'
  });
});
