$(document).on('turbolinks:load', function(){
  $('#next_content').click(warnUnsavedAnswer);
  $('#previous_content').click(warnUnsavedAnswer);
  $('#continue_content').click(function(){
    window.location = $(this).attr('next-content');
  });

  function warnUnsavedAnswer(e){
    e.preventDefault();

    if($('#new_answer').length){
      $('#continue_content').attr('next-content', $(this).attr('href'));
      $('#warning-modal').modal('show');
    }
    else{
      window.location = $(this).attr('href');
    }
  }
});
