class QuizQuestionMembersController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin
  before_action :set_quiz_question, only: [:edit, :update, :destroy]

  add_breadcrumb (ENV['COMPANY_NAME'].nil? ? "Inicio" : ENV['COMPANY_NAME']), :root_path
  add_breadcrumb "Programas", :programs_path
  def create
    @quiz=Quiz.find(quiz_question_params[:quiz_id])
    if @quiz.quiz_questions.sum(:points) + params[:quiz_question][:points].to_i <= 100
      @quiz_question = QuizQuestion.new(quiz_question_params)
      if @quiz_question.save
        redirect_to :back
      else
        render :new
      end
    else
      redirect_to :back, alert: "El puntaje supera el limite permitido o las preguntas existentes tienen la puntuacion tope" 
    end
  end

  def edit
    add_breadcrumb @quiz_question.quiz.chapter_content.chapter.program.name, program_path(@quiz_question.quiz.chapter_content.chapter.program) 
    add_breadcrumb "<a href='#{chapter_quiz_program_path(@quiz_question.quiz.chapter_content.chapter, @quiz_question.quiz.chapter_content)}'>#{@quiz_question.quiz.name}</a>".html_safe
    add_breadcrumb "<a class='active' href='#{edit_quiz_question_member_path(@quiz_question)}'>#{@quiz_question.question_text}</a>".html_safe
  end

  def update
    if @quiz_question.update(quiz_question_params)
      redirect_to chapter_quiz_program_path(@quiz_question.quiz.chapter_content.chapter,@quiz_question.quiz.chapter_content), notice: 'Entregable actualizado'
    else
      redirect_to :back
    end
  end  

  def destroy

    @quiz_question.destroy
    redirect_to :back, notice: 'Entregable eliminado'
  end 

  private
    def set_quiz_question
      @quiz_question = QuizQuestion.find(params[:id])
    end  
    def quiz_question_params
      params.require(:quiz_question).permit(:question_type, :question_text, :position, :answer_options, :support_text, :quiz_id, :points)
    end  
end
