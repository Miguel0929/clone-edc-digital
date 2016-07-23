class QuestionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_stage
  before_action :set_question, only: [:show, :edit, :update, :destroy]

  def new
    @question = @stage.questions.new
  end

  def show
  end

  def create
    @question = @stage.questions.build(question_params)

    if @question.save
      @stage.questions << @question
      redirect_to @stage.chapter.program
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @question.update_attributes(question_params)
      redirect_to @stage.chapter.program
    else
      render :edit
    end
  end

  def destroy
    ActiveRecord::Base.transaction do
      StageContent.where({coursable_type: 'Question', coursable_id: @question.id}).delete_all
      @question.destroy
    end

    redirect_to @stage.chapter.program
  end

  private
  def question_params
    params.require(:question).permit(:question_type, :question_text, :position, :answer_options)
  end

  def set_stage
    @stage = Stage.find(params[:stage_id])
  end

  def set_question
    @question = Question.find(params[:id])
  end
end
