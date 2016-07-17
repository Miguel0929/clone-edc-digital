class LessonsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_stage
  before_action :set_lesson, only: [:show, :edit, :update, :destroy]

  def new
    @lesson = @stage.lessons.new
  end

  def show
  end

  def create
    @lesson = @stage.lessons.build(lesson_params)

    if @lesson.save
      @stage.lessons << @lesson
      redirect_to @stage.chapter.program
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @lesson.update_attributes(lesson_params)
      redirect_to @stage.chapter.program
    else
      render :edit
    end
  end

  def destroy
    ActiveRecord::Base.transaction do
      StageContent.where({coursable_type: 'Lesson', coursable_id: @lesson.id}).delete_all
      @lesson.destroy
    end

    redirect_to @stage.chapter.program
  end

  private
  def lesson_params
    params.require(:lesson).permit(:content, :identifier)
  end

  def set_stage
    @stage = Stage.find(params[:stage_id])
  end

  def set_lesson
    @lesson = Lesson.find(params[:id])
  end
end
