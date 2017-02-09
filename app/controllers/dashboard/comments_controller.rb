class Dashboard::CommentsController < ApplicationController
  def create
    question = Question.find(params[:question_id])
    comment = Comment.new(user: current_user, question: question, content: params[:comment][:content], owner: current_user)
    comment.save

    redirect_to router_dashboard_chapter_content_answers_path(question.chapter_content)
  end
end
