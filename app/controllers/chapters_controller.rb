class ChaptersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_program
  before_action :set_chapter, only: [:edit, :update, :destroy]

  def new
    @chapter = @program.chapters.new
  end

  def create
    @chapter = @program.chapters.new(chapter_params)

    if @chapter.save
      redirect_to @program
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @chapter.update(chapter_params)
      redirect_to @program
    else
      render :edit
    end
  end

  def destroy
     @chapter.destroy

     redirect_to @program
  end

  private
  def chapter_params
    params.require(:chapter).permit(:name)
  end

  def set_program
    @program = Program.find(params[:program_id])
  end

  def set_chapter
    @chapter = Chapter.find(params[:id])
  end
end
