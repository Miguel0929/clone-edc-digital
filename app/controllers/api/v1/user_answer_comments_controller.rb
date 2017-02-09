class Api::V1::UserAnswerCommentsController < Api::V1::BaseController
  def index
    @comments = Comment.where(question_id: params[:question_id], owner_id: params[:user_id])

    render json: @comments
  end
end
