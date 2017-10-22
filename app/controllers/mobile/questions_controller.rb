class Mobile::QuestionsController < Mobile::BaseController
  before_action :authorize

  def show
    question = Question.find(params[:id])
    answer = question.answers.find_by(user: current_user)

    parsed_answer = []
    unless answer.nil?
      if question.checkbox?
        parsed_answer = answer.answer_text.split('\n')
      end
    end

    render json: { question: question, answer: answer, parsed_answer: parsed_answer}
  end
end
