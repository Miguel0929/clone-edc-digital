class Dashboard::CommentsController < ApplicationController
  def create
    answer = Answer.find(params[:answer_id]) 
    comment = Comment.new(user: current_user, answer: answer, content: params[:comment][:content])
    comment.save

    redirect_to dashboard_chapter_content_answer_path(answer.question.chapter_content, answer)
  end
end
