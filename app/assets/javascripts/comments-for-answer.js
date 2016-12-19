$(document).on('turbolinks:load', function(){
  $('.comments-count').click(function(event) {
    event.preventDefault();
    if($(this).data('total') === 0) {
      return
    }

    var data = {
      user: $(this).data('user'),
      answer: $(this).data('answer'),
      chapter: $(this).data('content'),
    }

    $.ajax({
      url: '/api/v1/user_answer_comments',
      type: 'GET',
      dataType: 'json',
      data: { user_id: data.user, answer_id: data.answer },
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

        $('.answer-comment-link').attr('href', "/dashboard/course/" + data.chapter +"/answers/" + data.answer);
        $('.answer-comments-body').html(comments.join());
        $('#answer-comments').modal('show');
      }
    });
  });
});
