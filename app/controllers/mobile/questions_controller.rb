class Mobile::QuestionsController < Mobile::BaseController
  before_action :authorize

  def show
    question = Question.find(params[:id])
    answer = question.answers.find_by(user: current_user)

    render json: { question: question, answer: answer }
  end
end
