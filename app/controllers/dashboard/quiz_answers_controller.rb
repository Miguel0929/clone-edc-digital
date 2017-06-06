class Dashboard::QuizAnswersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_quiz
  
  def create
    params[:answers].each_with_index do |answer, index|
      answer[1][:correct] = answer[1][:answer_text].split(' ~ ')[1] == 'correcta' ? true : false 
      answer[1][:answer_text] = answer[1][:answer_text].split(' ~ ')[0]  
      QuizAnswer.create(answer_params(answer))
    end
    redirect_to detail_dashboard_quiz_path(@quiz)
  end

  private
    def set_quiz
      @quiz = Quiz.find(params[:quiz_id])
    end

    def build_question
      @quiz_question = QuizQuestion.find(params[:quiz_question_id] )
    end

    def build_answer
      @quiz_question.quiz_answers.find_by(user: current_user, quiz_question: @quiz_question) || @quiz_question.quiz_answers.new(user: current_user) 
    end

    def answer_params(custom_params)
      ActionController::Parameters.new(custom_params[1]).permit(:user_id, :quiz_question_id, :answer_text, :correct)
    end
end
