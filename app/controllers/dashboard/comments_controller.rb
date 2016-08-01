class Dashboard::CommentsController < ApplicationController
  def create
    answer = Answer.find(params[:answer_id]) 
    comment = Comment.new(user: current_user, answer: answer, content: params[:comment][:content])
    comment.save

    redirect_to new_dashboard_stage_content_answer_path(StageContent.find_by(coursable_type: 'Question', coursable_id: answer.question.id))
  end
end
