class QuestionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_chapter
  before_action :set_question, only: [:edit, :update, :destroy]

  def new
    @question = @chapter.questions.new
  end

  def create
    @question = @chapter.questions.build(question_params)

    if @question.save
      @chapter.questions << @question
      redirect_to @chapter.program
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @question.update_attributes(question_params)
      redirect_to @chapter.program
    else
      render :edit
    end
  end

  def destroy
    ActiveRecord::Base.transaction do
      ChapterContent.where({coursable_type: 'Question', coursable_id: @question.id}).delete_all
      @question.destroy
    end

    redirect_to @chapter.program
  end

  private
  def question_params
    params.require(:question).permit(:question_type, :question_text, :position, :answer_options)
  end

  def set_chapter
    @chapter = Chapter.find(params[:chapter_id])
  end

  def set_question
    @question = Question.find(params[:id])
  end
end
