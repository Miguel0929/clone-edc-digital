class Dashboard::QuizzesController < ApplicationController
  before_action :authenticate_user!
  add_breadcrumb "EDCDIGITAL", :root_path

  def index
    @quizzes = current_user.group.quizzes
  end

  def show
    @quiz = Quiz.find(params[:id])
  end

  def apply
    @answers = []
    @quiz = Quiz.find(params[:id])
    @quiz.quiz_questions.each do |question|
      @answers << QuizAnswer.new(quiz_question_id: question.id, user_id: current_user.id)
    end
  end
end
