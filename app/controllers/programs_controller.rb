class ProgramsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_program, only: [:show, :edit, :update, :destroy, :clone]

  add_breadcrumb "Administrador", :root_path

  def index
    add_breadcrumb "<a class='active' href='#{programs_path}'>Programas</a>".html_safe

    @programs = Program.all
  end

  def show
    add_breadcrumb "Programas", :programs_path
    add_breadcrumb "<a class='active' href='#{program_path(@program)}'>#{@program.name}</a>".html_safe

  end

  def new
    add_breadcrumb "Programas", :programs_path
    add_breadcrumb "<a class='active' href='#{new_program_path}'>Crear programa</a>".html_safe

    @program = Program.new
  end

  def create
    add_breadcrumb "Programas", :programs_path
    add_breadcrumb "<a class='active' href='#{new_program_path}'>Crear programa</a>".html_safe

    @program = Program.new(program_params)

    if @program.save
      redirect_to @program
    else
      render :new
    end
  end

  def edit
    add_breadcrumb "Programas", :programs_path
    add_breadcrumb "<a class='active' href='#{edit_program_path(@program)}'>#{@program.name}</a>".html_safe
  end

  def update
    add_breadcrumb "Programas", :programs_path
    add_breadcrumb "<a class='active' href='#{edit_program_path(@program)}'>#{@program.name}</a>".html_safe

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
