class DelireverableProgramsController < ApplicationController
  before_action :set_chapter
  before_action :authenticate_user!
  before_action :set_chapter_content, only: [:show,:destroy]

  add_breadcrumb "EDCDIGITAL", :root_path
  add_breadcrumb "Programas", :programs_path

  def new
    add_breadcrumb @chapter.program.name, program_path(@chapter.program)
    add_breadcrumb "<a class='active' href='#{new_chapter_delireverable_program_path(@chapter)}'>Nuevo contenido</a>".html_safe
  end

  def create
    @chapter_content=ChapterContent.new(coursable_id: params[:delireverable_package_id], coursable_type: "DelireverablePackage", chapter: @chapter)
    if @chapter_content.save
      #QueueNotification.create(category: 2, program: @chapter.program.id, url: dashboard_program_url(@chapter.program), detail: "up-lesson-#{@lesson.id}")
      redirect_to @chapter.program, notice: "Se agrego exitosamente el entregable"
    else
      render :new
    end
  end

  def destroy
    @chapter_content.destroy
    chapter_contents = @chapter.chapter_contents.map{ |cp| cp.id }
    chapter_contents.each_with_index do |id, index|
      ChapterContent.find(id).update_attributes({position: index + 1})
    end

    redirect_to @chapter.program, notice: "Se eliminó exitosamente el entregable"
  end  

  private
  def set_chapter
    @chapter = Chapter.find(params[:chapter_id])
  end
  def set_chapter_content
    @chapter_content = ChapterContent.find(params[:id])
  end 
end
