class StagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_chapter
  before_action :set_stage, only: [:edit, :update, :destroy]

  def new
    @stage = @chapter.stages.new
  end

  def create
    @stage = @chapter.stages.new(stage_params)

    if @stage.save
      redirect_to @chapter.program
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @stage.update(stage_params)
      redirect_to @chapter.program
    else
      render :edit
    end
  end

  def destroy
     @stage.destroy

     redirect_to @chapter.program
  end

  private
  def stage_params
    params.require(:stage).permit(:name)
  end

  def set_stage
    @stage = Stage.find(params[:id])
  end

  def set_chapter
    @chapter = Chapter.find(params[:chapter_id])
  end
end
