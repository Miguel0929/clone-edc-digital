class ChaptersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_program
  before_action :set_chapter, only: [:edit, :update, :destroy, :clone]

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

  def sort
    params[:chapter].each_with_index do |id, index|
      Chapter.find(id).update_attributes({position: index + 1})
    end

    render nothing: true
  end

  def clone
    clone_chapter = @chapter.deep_clone do |original, kopy|
      kopy.name = "#{original.name} copia"
    end


    @chapter.chapter_contents.each do |chapter_content|
      model = chapter_content.model
      if model.is_a?(Lesson)
        clone_chapter.lessons << model.deep_clone
      elsif model.is_a?(Question)
        clone_chapter.questions << model.deep_clone do |original, kopy|
          kopy.support_image = original.support_image
          kopy.rubrics = original.rubrics.map(&:deep_clone)
        end
      end
    end

    clone_chapter.save

    redirect_to @program
  end

  private
  def chapter_params
    params.require(:chapter).permit(:name, :points)
  end

  def set_program
    @program = Program.find(params[:program_id])
  end

  def set_chapter
    @chapter = Chapter.find(params[:id])
  end
end
