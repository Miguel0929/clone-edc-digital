class Dashboard::QuizzesController < ApplicationController
  before_action :authenticate_user!
  add_breadcrumb "EDCDIGITAL", :root_path

  def index
    add_breadcrumb "<a class='active' href='#{dashboard_quizzes_path}'>Exámenes</a>".html_safe
    @quizzes = current_user.group.quizzes
  end

  def show
    @quiz = Quiz.find(params[:id])
    add_breadcrumb "<a href='#{dashboard_quizzes_path}'>Exámenes</a>".html_safe    
    add_breadcrumb "<a class='active' href='#{dashboard_quiz_path(@quiz)}'>#{@quiz.name}</a>".html_safe
  end

  def detail
    @quiz = Quiz.find(params[:id])
    ids = @quiz.quiz_questions.map{ |q| q.id }
    @answers = QuizAnswer.where(quiz_question_id: ids, user_id: current_user.id)
    add_breadcrumb "<a href='#{dashboard_quizzes_path}'>Exámenes</a>".html_safe    
    add_breadcrumb "<a class='active' href='#{dashboard_quiz_path(@quiz)}'>#{@quiz.name}</a>".html_safe
  end

  def apply
    @answers = []
    @quiz = Quiz.find(params[:id])
    @quiz.quiz_questions.each do |question|
      @answers << QuizAnswer.new(quiz_question_id: question.id, user_id: current_user.id)
    end
    add_breadcrumb "<a href='#{dashboard_quizzes_path}'>Exámenes</a>".html_safe    
    add_breadcrumb "<a class='active' href='#{dashboard_quiz_path(@quiz)}'>#{@quiz.name}</a>".html_safe
    redirect_to dashboard_quizzes_path if @quiz.answered(current_user) > 0
  end
end
