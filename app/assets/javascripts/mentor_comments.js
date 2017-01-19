$(document).on('turbolinks:load', function(){
  $('.mentor-comment-answer').click(function() {
    var $inputAnswer = $('<input type="hidden" name="comment[answer_id]"/>').val($(this).data('answer'))
    var $inputOrigin = $('<input type="hidden" name="origin"/>').val(window.location.pathname);
    $('.mentor-comment-answer-form').html('').append($inputAnswer).append($inputOrigin);
    $('#mentor-modal').modal('show');
  });
});
