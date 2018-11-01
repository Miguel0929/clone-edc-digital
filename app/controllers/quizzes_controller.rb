class QuizzesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin
  before_action :set_quiz, only: [:show, :edit, :update, :destroy]

  add_breadcrumb (ENV['COMPANY_NAME'].nil? ? "Inicio" : ENV['COMPANY_NAME']), :root_path

  def index
    add_breadcrumb "<a class='active' href='#{quizzes_path}'>Evaluaciones</a>".html_safe
    @quizzes = Quiz.all.includes(:program)
  end

  def show
    add_breadcrumb "<a href='#{quizzes_path}'>Evaluaciones</a>".html_safe
    add_breadcrumb "<a class='active' href='#{quiz_path(@quiz)}'>#{@quiz.name}</a>".html_safe
  end

  def new
    add_breadcrumb "<a href='#{quizzes_path}'>Evaluaciones</a>".html_safe
    add_breadcrumb "<a class='active' href='#{new_quiz_path(@quiz)}'>Nuevo</a>".html_safe
    @quiz = Quiz.new
  end

  def edit
    add_breadcrumb "<a href='#{quizzes_path}'>Evaluaciones</a>".html_safe
    add_breadcrumb "<a class='active' href='#{edit_quiz_path(@quiz)}'>Editar</a>".html_safe
  end

  def create
    @quiz = Quiz.new(quiz_params)
    @quiz.tipo=1
    respond_to do |format|
      if @quiz.save
        format.html { redirect_to @quiz, notice: 'Quiz creado exitosamente.' }
        format.json { render :show, status: :created, location: @quiz }
      else
        format.html { render :new }
        format.json { render json: @quiz.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @quiz.update(quiz_params)
        format.html { redirect_to @quiz, notice: 'Quiz actualizado exitosamente.' }
        format.json { render :show, status: :ok, location: @quiz }
      else
        format.html { render :edit }
        format.json { render json: @quiz.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @quiz.destroy
    respond_to do |format|
      format.html { redirect_to quizzes_url, notice: 'Quiz eliminado exitosamente.' }
      format.json { head :no_content }
    end
  end  

  private
    def set_quiz
      @quiz = Quiz.find(params[:id])
    end

    def quiz_params
      params.require(:quiz).permit(:name, :description, :program_id, group_ids: [])
    end
end
