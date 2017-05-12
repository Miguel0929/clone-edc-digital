class Dashboard::QuizAnswersController < ApplicationController
  before_action :authenticate_user!
  
  def create
    raise :exception
    #params[:answers].each_with_index do |answer, index|
     # QuizAnswer.create(answer_params(answer))
    #end
    #redirect_to quiz_question.quiz
  end

  private
    def build_question
      @quiz_question = QuizQuestion.find(params[:quiz_question_id] )
    end

    def build_answer
      @quiz_question.quiz_answers.find_by(user: current_user, quiz_question: @quiz_question) || @quiz_question.quiz_answers.new(user: current_user) 
    end

    def answers_params(custom_params)
      ActionController::Parameters.new(custom_params[1]).permit(:user_id, :quiz_question_id, :answer_text)
    end
end
