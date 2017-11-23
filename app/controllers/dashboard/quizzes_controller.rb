class Dashboard::QuizzesController < ApplicationController
  before_action :authenticate_user!
  add_breadcrumb "EDC DIGITAL", :root_path
  helper_method :right_answer
  helper_method :evaluating_quiz

  def index
    add_breadcrumb "<a class='active' href='#{dashboard_quizzes_path}'>Exámenes</a>".html_safe
    quizzes_ruta = current_user.group.learning_path.learning_path_contents.where(content_type: "Quiz").pluck(:content_id)
    quizzes_group = current_user.group.quizzes.pluck(:id)
    aux=quizzes_ruta.concat(quizzes_group)
    @quizzes = Quiz.where(id: aux)

  end

  def show
    @quiz = Quiz.find(params[:id])
    add_breadcrumb "<a href='#{dashboard_quizzes_path}'>Exámenes</a>".html_safe    
    add_breadcrumb "<a class='active' href='#{dashboard_quiz_path(@quiz)}'>#{@quiz.name}</a>".html_safe
    redirect_to dashboard_quizzes_path unless @quiz.answered(current_user) > 0
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
    if @quiz.answered(current_user) > 0
      flash[:notice] = "Este es tu intento número #{Attempt.where(quiz_id: @quiz.id, user_id: current_user.id).count + 1} la calificación que obtengas será la se tomará en cuenta"
    end
    add_breadcrumb "<a href='#{dashboard_quizzes_path}'>Exámenes</a>".html_safe    
    add_breadcrumb "<a class='active' href='#{dashboard_quiz_path(@quiz)}'>#{@quiz.name}</a>".html_safe
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
end
