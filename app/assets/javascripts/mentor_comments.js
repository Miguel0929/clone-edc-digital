$(document).on('turbolinks:load', function(){
  $('.mentor-comment-answer').click(function() {
    var $inputAnswer = $('<input type="hidden" name="comment[answer_id]"/>').val($(this).data('answer'))
    var $inputOrigin = $('<input type="hidden" name="origin"/>').val(window.location.pathname);
    var $inputComment = $('<input type="hidden" name="comment_id"/>').val($(this).data('comment'));
    $('.mentor-comment-answer-form').html('').append($inputAnswer).append($inputOrigin).append($inputComment);
    $('#mentor-modal').modal('show');
  });
});
