class LessonsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_chapter
  before_action :set_lesson, only: [:show, :edit, :update, :destroy]

  def new
    @lesson = @chapter.lessons.new
  end

  def show
  end

  def create
    @lesson = @chapter.lessons.build(lesson_params)

    if @lesson.save
      @chapter.lessons << @lesson
      NewContentNotificationJob.perform_later(@chapter.program)
      redirect_to @chapter.program
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @lesson.update_attributes(lesson_params)
      redirect_to @chapter.program
    else
      render :edit
    end
  end

  def destroy
    ActiveRecord::Base.transaction do
      ChapterContent.where({coursable_type: 'Lesson', coursable_id: @lesson.id}).delete_all
      @lesson.destroy
    end

    redirect_to @chapter.program
  end

  private
  def lesson_params
    params.require(:lesson).permit(:content, :identifier, :video_url)
  end

  def set_chapter
    @chapter = Chapter.find(params[:chapter_id])
  end

  def set_lesson
    @lesson = Lesson.find(params[:id])
  end
end
