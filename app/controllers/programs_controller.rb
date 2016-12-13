class ProgramsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_program, only: [:show, :edit, :update, :destroy, :clone]

  def index
    @programs = Program.all
  end

  def show
  end

  def new
    @program = Program.new
  end

  def create
    @program = Program.new(program_params)

    if @program.save
      redirect_to @program
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @program.update(program_params)
      redirect_to @program
    else
      render :edit
    end
  end

  def destroy
     @program.destroy

     redirect_to programs_path
  end

  def clone
    #TODO create a cloner service

    program = @program.deep_clone do |original, kopy|
       kopy.name = "#{original.name} copia"
       kopy.cover = original.cover
    end

    chapters = []
    @program.chapters.each do |chapter|
      clone_chapter = chapter.deep_clone

      chapter.chapter_contents.each do |chapter_content|
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

      chapters << clone_chapter
    end

    program.chapters = chapters

    program.save

    redirect_to programs_path
  end

  private
  def program_params
    params.require(:program).permit(:name, :description, :cover)
  end

  def set_program
    @program = Program.find(params[:id])
  end
end
