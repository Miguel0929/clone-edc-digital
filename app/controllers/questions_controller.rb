class QuestionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_chapter
  before_action :set_question, only: [:edit, :update, :destroy, :clone]

  add_breadcrumb "EDCDIGITAL", :root_path
  add_breadcrumb "Programas", :programs_path

  def new
    add_breadcrumb @chapter.program.name, program_path(@chapter.program)
    add_breadcrumb "<a class='active' href='#{new_chapter_question_path(@chapter)}'>Nueva pregunta</a>".html_safe

    @question = @chapter.questions.new
    ['Deficiente', 'Regular', 'Bueno', 'Excelente'].each do |criteria|
      @question.rubrics.new({criteria: criteria})
    end
  end

  def create
    add_breadcrumb @chapter.program.name, program_path(@chapter.program)
    add_breadcrumb "<a class='active' href='#{new_chapter_question_path(@chapter)}'>Nueva pregunta</a>".html_safe

    @question = @chapter.questions.build(question_params)

    if @question.save
      @chapter.questions << @question
      NewContentNotificationJob.perform_later(@chapter.program)
      redirect_to @chapter.program, notice: "Se creo exitosamente la pregunta #{@question.question_text}"
    else
      render :new
    end
  end

  def edit
    add_breadcrumb @chapter.program.name, program_path(@chapter.program)
    add_breadcrumb "<a class='active' href='#{edit_chapter_question_path(@chapter, @question)}'>#{@question.question_text}</a>".html_safe
  end

  def update
    add_breadcrumb @chapter.program.name, program_path(@chapter.program)
    add_breadcrumb "<a class='active' href='#{edit_chapter_question_path(@chapter, @question)}'>#{@question.question_text}</a>".html_safe

    if @question.update_attributes(question_params)
      redirect_to @chapter.program, notice: "Se actualizó exitosamente la pregunta  #{@question.question_text}"
    else
      render :edit
    end
  end

  def destroy
    ActiveRecord::Base.transaction do
      ChapterContent.where({coursable_type: 'Question', coursable_id: @question.id}).delete_all
      @question.destroy
    end

    redirect_to @chapter.program, notice: "Se eliminó exitosamente la pregunta #{@question.question_text}"
  end

  def clone
    question_clone =  @question.deep_clone do |original, kopy|
      kopy.question_text = "#{original.question_text} copia"
      kopy.support_image = original.support_image
      kopy.rubrics = original.rubrics.map(&:deep_clone)
    end

    @chapter.questions << question_clone

    redirect_to @chapter.program, notice: "Se creo exitosamente la pregunta #{question_clone.question_text}"
  end

  private
  def question_params
    params.require(:question)
      .permit(:question_type, :question_text, :position, :answer_options,
              :support_text, :support_image, :points, rubrics_attributes: [:id, :criteria, :base])
  end

  def set_chapter
    @chapter = Chapter.find(params[:chapter_id])
  end

  def set_question
    @question = Question.find(params[:id])
  end
end
