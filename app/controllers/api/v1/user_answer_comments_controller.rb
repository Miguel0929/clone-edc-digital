class Api::V1::UserAnswerCommentsController < Api::V1::BaseController
  def index
    answer = Answer.find_by('id = ? and user_id = ?', params[:answer_id], params[:user_id])
    @comments = answer.comments rescue []

    render json: @comments
  end
end
