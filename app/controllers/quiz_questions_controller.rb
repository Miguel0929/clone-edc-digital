class QuizQuestionsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin
  before_action :set_quiz, only: [:new, :create, :destroy, :edit, :update, :support]

  add_breadcrumb "EDC DIGITAL", :root_path

  def new
    add_breadcrumb "<a href='#{quizzes_path}'>Evaluaciones</a>".html_safe
    add_breadcrumb "<a href='#{quiz_path(@quiz)}'>#{@quiz.name}</a>".html_safe
    add_breadcrumb "<a class='active' href='#{quiz_quiz_questions_path}'>Nueva pregunta</a>".html_safe
    @quiz_question = @quiz.quiz_questions.build
  end

  def edit
    add_breadcrumb "<a href='#{quizzes_path}'>Evaluaciones</a>".html_safe
    add_breadcrumb "<a href='#{quiz_path(@quiz)}'>#{@quiz.name}</a>".html_safe
    @quiz_question = QuizQuestion.find(params[:id])
    add_breadcrumb "<a class='active' href='#{edit_quiz_quiz_question_path(@quiz, @quiz_question)}'>Editar pregunta</a>".html_safe
  end

  def create
    if @quiz.quiz_questions.sum(:points) + params[:quiz_question][:points].to_i <= 100
      @quiz_question = QuizQuestion.new(quiz_question_params)
      if @quiz_question.save
        redirect_to :back, notice: "Pregunta agregada"
      else
        render :new
      end
    else
      redirect_to :back, alert: "El puntaje supera el limite permitido o las preguntas existentes tienen la puntuacion tope" 
    end
  end

  def update
    params[:quiz_question][:points] = '0' if params[:quiz_question][:points].nil? 
    @quiz_question = QuizQuestion.find(params[:id])
    if (@quiz.quiz_questions.sum(:points) - (@quiz_question.points.nil? ? 0 : @quiz_question.points)) + params[:quiz_question][:points].to_i <= 100
      if @quiz_question.update(quiz_question_params)
        redirect_to @quiz
      else
        render :edit
      end
    else
      redirect_to edit_quiz_quiz_question_path(@quiz, @quiz_question), alert: "El puntaje supera el limite permitido o laspreguntas existentes tienen la puntuacion tope"
    end
  end

  def destroy
    @quiz_question = QuizQuestion.find(params[:id])
    @quiz_question.destroy
    redirect_to @quiz
  end

  def support
    add_breadcrumb "<a href='#{quizzes_path}'>Evaluaciones</a>".html_safe
    add_breadcrumb "<a href='#{quiz_path(@quiz)}'>#{@quiz.name}</a>".html_safe
    @quiz_question = QuizQuestion.find(params[:id])
    add_breadcrumb "<a class='active' href='#{ support_quiz_quiz_question_path(@quiz, @quiz_question) }'>Nueva pregunta</a>".html_safe
  end

  private
    def set_quiz
      @quiz = Quiz.find(params[:quiz_id])
    end

    def quiz_question_params
      params.require(:quiz_question).permit(:question_type, :question_text, :position, :answer_options, :support_text, :quiz_id, :points)
    end
end
