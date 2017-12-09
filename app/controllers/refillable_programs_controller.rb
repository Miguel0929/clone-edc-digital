class RefillableProgramsController < ApplicationController
  before_action :set_chapter
  before_action :authenticate_user!
  before_action :set_chapter_content, only: [:show,:destroy,:edit,:update,:clone]

  add_breadcrumb "EDCDIGITAL", :root_path
  add_breadcrumb "Programas", :programs_path

  def new
    @template_refilable=TemplateRefilable.new
    add_breadcrumb @chapter.program.name, program_path(@chapter.program)
    add_breadcrumb "<a class='active' href='#{new_chapter_refillable_program_path(@chapter)}'>Nuevo contenido</a>".html_safe
  end
  def create
    @template_refilable = TemplateRefilable.new(template_refilable_params)
    @template_refilable.tipo = 0
    if @template_refilable.save
      @chapter.template_refilables << @template_refilable
      #QueueNotification.create(category: 2, program: @chapter.program.id, url: dashboard_program_url(@chapter.program), detail: "up-lesson-#{@lesson.id}")
      redirect_to @chapter.program, notice: "Se agrego exitosamente el rellenable"
    else
      render :new
    end
  end
  def destroy
    @template_refilable = @chapter_content.model
    ActiveRecord::Base.transaction do
      @chapter_content.destroy
    end

    chapter_contents = @chapter.chapter_contents.map{ |cp| cp.id }
    chapter_contents.each_with_index do |id, index|
      ChapterContent.find(id).update_attributes({position: index + 1})
    end

    redirect_to @chapter.program, notice: "Se eliminó exitosamente el rellenable"
  end
  def edit
    @template_refilable = @chapter_content.model
    add_breadcrumb @chapter.program.name, program_path(@chapter.program)
    add_breadcrumb "<a class='active' href='#{edit_chapter_refillable_program_path(@chapter, @template_refilable)}'>#{@template_refilable.name}</a>".html_safe
  end
  def update
    @template_refilable = @chapter_content.model
    if @template_refilable.update(template_refilable_params)
      #QueueNotification.create(category: 3, program: @chapter.program.id, url: dashboard_program_url(@chapter.program), detail: "edit-question-#{@question.id}")
      redirect_to program_path(@chapter.program), notice: "Se actualizó exitosamente el rellenable  #{@template_refilable.name}"
    else
      render :edit
    end
  end
  def clone
    @template_refilable = @chapter_content.model
    refilable_clone = @template_refilable.deep_clone do |original, kopy|
      kopy.name = "#{original.name} copia"
      kopy.tipo = 0
    end  

    @chapter.template_refilables << refilable_clone

    redirect_to program_path(@chapter.program), notice: "Se creo exitosamente el rellenable #{refilable_clone.name}"

  end 
  private
  def set_chapter
    @chapter = Chapter.find(params[:chapter_id])
  end
  def set_chapter_content
    @chapter_content = ChapterContent.find(params[:id])
  end
  def template_refilable_params
    params.require(:template_refilable).permit(:name, :description, :content)
  end 
end
