class ChaptersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_program
  before_action :set_chapter, only: [:edit, :update, :destroy, :clone]

  add_breadcrumb "EDCDIGITAL", :root_path
  add_breadcrumb "Programas", :programs_path

  def new
    add_breadcrumb @program.name, program_path(@program)
    add_breadcrumb "<a class='active' href='#{new_program_chapter_path(@program)}'>Crear módulo</a>".html_safe

    @chapter = @program.chapters.new
  end

  def create
    add_breadcrumb @program.name, program_path(@program)
    add_breadcrumb "<a class='active' href='#{new_program_chapter_path(@program)}'>Crear módulo</a>".html_safe

    @chapter = @program.chapters.new(chapter_params)

    if @chapter.save
      redirect_to @program, notice: "Se creo exitosamente el módulo #{@chapter.name}"
    else
      render :new
    end
  end

  def edit
    add_breadcrumb @program.name, program_path(@program)
    add_breadcrumb "<a class='active' href='#{program_chapter_path(@program, @chapter)}'>#{@chapter.name}</a>".html_safe
  end

  def update
    add_breadcrumb @program.name, program_path(@program)
    add_breadcrumb "<a class='active' href='#{program_chapter_path(@program, @chapter)}'>#{@chapter.name}</a>".html_safe

    if @chapter.update(chapter_params)
      redirect_to @program, notice: "Se actualizó exitosamente el módulo #{@chapter.name}"
    else
      render :edit
    end
  end

  def destroy
     @chapter.destroy

     redirect_to @program, notice: "Se eliminó exitosamente el módulo #{@chapter.name}"
  end

  def sort
    params[:accordion_chapter].each_with_index do |id, index|
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

    redirect_to @program, notice: "Se creo exitosamente el módulo #{clone_chapter.name}"
  end

  private
  def chapter_params
    params.require(:chapter).permit(:name, :points, evaluations_attributes: [
      :id, :name, :points, :position, :excelent, :good, :regular, :bad, :_destroy
    ])
  end

  def set_program
    @program = Program.find(params[:program_id])
  end

  def set_chapter
    @chapter = Chapter.find(params[:id])
  end
end
