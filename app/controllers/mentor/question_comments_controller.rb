
class Mentor::QuestionCommentsController < ApplicationController
  def create
    question = Question.find(params[:question_id])
    comment = question.comments.create(comment_params)

    redirect_to mentor_question_path(question, user_id: comment.owner_id)
  end

  def comment_params
    params.permit(:content, :owner_id, :user_id)
  end
end
