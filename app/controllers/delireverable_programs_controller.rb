class DelireverableProgramsController < ApplicationController
  before_action :set_chapter
  before_action :authenticate_user!
  before_action :set_chapter_content, only: [:show,:destroy,:edit,:update,:clone]

  add_breadcrumb (ENV['COMPANY_NAME'].nil? ? "Inicio" : ENV['COMPANY_NAME']), :root_path
  add_breadcrumb "Programas", :programs_path

  def new
    @delireverable_package= DelireverablePackage.new
    add_breadcrumb @chapter.program.name, program_path(@chapter.program)
    add_breadcrumb "<a class='active' href='#{new_chapter_delireverable_program_path(@chapter)}'>Nuevo contenido</a>".html_safe
  end

  def create
    @delireverable_package = DelireverablePackage.new(delireverable_package_params)
    @delireverable_package.tipo=0
    if @delireverable_package.save
      @chapter.delireverable_packages << @delireverable_package
      #QueueNotification.create(category: 2, program: @chapter.program.id, url: dashboard_program_url(@chapter.program), detail: "up-lesson-#{@lesson.id}")
      redirect_to chapter_delireverable_program_path(@chapter, @delireverable_package.chapter_content), notice: 'Paquete creado'
    else
      render :new
    end
  end
  def show
    @delireverable_package = @chapter_content.model
    @delireverables = @delireverable_package.delireverables
    @delireverable=Delireverable.new 
    add_breadcrumb @chapter.program.name, program_path(@chapter.program)
    add_breadcrumb "<a class='active' href='#{chapter_delireverable_program_path(@chapter, @chapter_content)}'>#{@chapter_content.model.name}</a>".html_safe
  end  

  def destroy
    @chapter_content.destroy
    chapter_contents = @chapter.chapter_contents.map{ |cp| cp.id }
    chapter_contents.each_with_index do |id, index|
      ChapterContent.find(id).update_attributes({position: index + 1})
    end

    redirect_to @chapter.program, notice: "Se eliminó exitosamente el entregable"
  end
  def edit
    @delireverable_package = @chapter_content.model
    add_breadcrumb @chapter.program.name, program_path(@chapter.program)
    add_breadcrumb "<a class='active' href='#{edit_chapter_delireverable_program_path(@chapter, @chapter_content)}'>#{@chapter_content.model.name}</a>".html_safe
  end 

  def update
    @delireverable_package = @chapter_content.model
    if @delireverable_package.update(delireverable_package_params)
      redirect_to program_path(@chapter.program), notice: 'Paquete actualizado'
    else
      render :edit
    end
  end
  def clone
    @delireverable_package=@chapter_content.model
    delireverable_package_clone = @delireverable_package.deep_clone do |original, kopy|
      kopy.name = "#{original.name} copia"
      kopy.tipo = 0 
    end  

    @chapter.delireverable_packages << delireverable_package_clone
    @delireverable_package.delireverables.each do |delireverable|
      aux=Delireverable.new(name: delireverable.name, description: delireverable.description, delireverable_package: delireverable_package_clone, file: delireverable.file, position: delireverable.position) 
      aux.save
    end 
    redirect_to program_path(@chapter.program), notice: "Se creo exitosamente el paquete de entregables #{delireverable_package_clone.name}"
  end   



  private
  def set_chapter
    @chapter = Chapter.find(params[:chapter_id])
  end
  def set_chapter_content
    @chapter_content = ChapterContent.find(params[:id])
  end
  def delireverable_package_params
    params.require(:delireverable_package).permit(:name, :description)
  end 
end
