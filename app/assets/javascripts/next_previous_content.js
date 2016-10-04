$(document).on('turbolinks:load', function(){
  $('#next_content').click(warnUnsavedAnswer);
  $('#previous_content').click(warnUnsavedAnswer);
  $('#continue_content').click(function(){
    window.location = $(this).attr('next-content');
  });

  function warnUnsavedAnswer(e){
    if($('#new_answer').length){
      e.preventDefault();
      $('#continue_content').attr('next-content', $(this).attr('href'));
      $('#warning-modal').modal('show');
    }
  }
});
