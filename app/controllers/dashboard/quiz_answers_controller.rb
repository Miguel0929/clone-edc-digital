class Dashboard::QuizAnswersController < ApplicationController
  before_action :authenticate_user!
  before_action :build_question

  private
    def build_question
      @quiz_question = QuizQuestion.find(params[:quiz_question_id] 
    end

    def build_answer
      @quiz_question.quiz_answers.find_by(user: current_user, quiz_question: @quiz_question) || @quiz_question.quiz_answers.new(user: current_user) 
    end
end
