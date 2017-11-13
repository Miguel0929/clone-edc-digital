class Mobile::QuestionsController < Mobile::BaseController
  before_action :authorize

  def show
    question = Question.find(params[:id])
    answer = question.answers.find_by(user: current_user)

    parsed_answer = []
    parsed_answer_index = []
    options = question.answer_options.split("\n")
    unless answer.nil?
      if question.checkbox?
        parsed_answer = answer.answer_text.split('\n')
        parsed_answer_index = answer.answer_text.split('\n').map {|answer| options.index(answer)}
      end
    end

    render json: { question: question, answer: answer, parsed_answer: parsed_answer, options: options, parsed_answer_index: parsed_answer_index}
  end
end
