class Dashboard::QuizzesController < ApplicationController
  before_action :authenticate_user!
  before_action :redirect_to_support, if: :student_have_group?
  before_action :set_quiz, only: [:show, :apply, :detail]
  before_action :redirect_to_quizzes, if: :permiso_quiz, only: [:show, :apply, :detail]  
  add_breadcrumb (ENV['COMPANY_NAME'].nil? ? "Inicio" : ENV['COMPANY_NAME']), :root_path
  helper_method :right_answer
  helper_method :evaluating_quiz
  include ActiveElementsHelper

  def index
    unless params[:user_id].present?
      if current_user.student? || current_user.mentor?
        add_breadcrumb "<a class='active' href='#{dashboard_quizzes_path}'>Evaluaciones</a>".html_safe
        @quizzes = get_active_elements(current_user, "quizzes")  
      end
    else
      @student = User.find(params[:user_id])
      add_breadcrumb "Estudiantes", :mentor_students_path
      add_breadcrumb "<a href='#{mentor_student_path(@student)}'>#{@student.email}</a>".html_safe
      add_breadcrumb "<a class='active' href='#{dashboard_quizzes_path(user_id: @student.id)}'>Evaluaciones</a>".html_safe
      @quizzes = @student.group.all_quizzes  
    end
    if !params[:program_id].nil?
      @quizzes = @quizzes.select {|x| x['program_id'] == params[:program_id].to_i }
      @program = Program.find(params[:program_id])
    end    
  end 

  def show
    add_breadcrumb "<a href='#{dashboard_quizzes_path}'>Evaluaciones</a>".html_safe    
    add_breadcrumb "<a class='active' href='#{dashboard_quiz_path(@quiz)}'>#{@quiz.name}</a>".html_safe
    redirect_to dashboard_quizzes_path unless @quiz.answered(current_user) > 0
  end

  def detail
    ids = @quiz.quiz_questions.map{ |q| q.id }
    @answers = QuizAnswer.where(quiz_question_id: ids, user_id: current_user.id)
    add_breadcrumb "<a href='#{dashboard_quizzes_path}'>Evaluaciones</a>".html_safe    
    add_breadcrumb "<a class='active' href='#{dashboard_quiz_path(@quiz)}'>#{@quiz.name}</a>".html_safe
  end

  def apply
    @answers = []
    @quiz.quiz_questions.each do |question|
      @answers << QuizAnswer.new(quiz_question_id: question.id, user_id: current_user.id)
    end
    if @quiz.answered(current_user) > 0
      flash[:notice] = "Este es tu intento número #{Attempt.where(quiz_id: @quiz.id, user_id: current_user.id).count + 1} la calificación que obtengas será la se tomará en cuenta"
    end

    if current_user.student?
      add_breadcrumb "<a href='#{dashboard_quizzes_path}'>Evaluaciones</a>".html_safe    
      add_breadcrumb "<a class='active' href='#{dashboard_quiz_path(@quiz)}'>#{@quiz.name}</a>".html_safe
    else
      student = User.find(params[:user_id])
      add_breadcrumb "Estudiantes", :mentor_students_path
      add_breadcrumb "<a href='#{mentor_student_path(student)}'>#{student.email}</a>".html_safe
      add_breadcrumb "<a href='#{dashboard_quizzes_path(user_id: student.id)}'>Evaluaciones</a>".html_safe
      add_breadcrumb "<a class='active' href='#{dashboard_quiz_path(@quiz, user_id: params[:user_id])}'>#{@quiz.name}</a>".html_safe
    end
  end

  def evaluating_quiz(rightones, yours)
    result = nil
    rightones.each do |rightone|
      if rightone == yours
        result = true
        break
      else
        result = false
      end
    end
    return result
  end

  def right_answer(question)
    options = QuizQuestion.find(question).answer_options.split /[\r\n]+/
    righty = [];

    options.each do |option|
      if option.include? "~ correcta" then righty << option.chomp(" ~ correcta") end
    end
    return righty
  end
  private
  def set_quiz
    @quiz = Quiz.find(params[:id])
  end

  def permiso_quiz
    if current_user.student?
      !current_user.group.all_quizzes.include?(@quiz)
    else
      false
    end    
  end  

  def redirect_to_quizzes
    redirect_to dashboard_quizzes_path, alert: 'No tienes asignado esta evaluación' 
  end   
end
