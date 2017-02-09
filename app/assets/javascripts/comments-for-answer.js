$(document).on('turbolinks:load', function(){
  $('.comments-count').click(function(event) {
    event.preventDefault();
    var data = {
      user: $(this).data('user'),
      question: $(this).data('question'),
      chapter: $(this).data('content'),
      question_url: $(this).data('url'),
    }

    $.ajax({
      url: '/api/v1/user_answer_comments',
      type: 'GET',
      dataType: 'json',
      data: { user_id: data.user, question_id: data.question },
      success: function (response) {
        var comments = [];
        var $template = $('#answer-comment-template');
        $.each(response, function(key, comment){
          comments.push(
            $template
            .html()
            .replace('{{user}}', comment.user.first_name)
            .replace('{{date}}', comment.created_at)
            .replace('{{content}}', comment.content)
          )
        });

        $('.answer-comment-link').attr('href', data.question_url);
        $('.answer-comments-body').html(comments.join());
        $('#answer-comments').modal('show');
      }
    });
  });
});
