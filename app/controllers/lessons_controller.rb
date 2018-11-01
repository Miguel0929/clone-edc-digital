class LessonsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_chapter
  before_action :set_lesson, only: [:show, :edit, :update, :destroy, :clone]
  before_action :require_admin
  add_breadcrumb (ENV['COMPANY_NAME'].nil? ? "Inicio" : ENV['COMPANY_NAME']), :root_path
  add_breadcrumb "Programas", :programs_path

  def new
    add_breadcrumb @chapter.program.name, program_path(@chapter.program)
    add_breadcrumb "<a class='active' href='#{new_chapter_lesson_path(@chapter)}'>Nuevo contenido</a>".html_safe

    @lesson = @chapter.lessons.new

    @program_attachments = ProgramAttachment.where(program_id: @chapter.program_id)
  end

  def show
    add_breadcrumb @chapter.program.name, program_path(@chapter.program)
    add_breadcrumb "<a class='active' href='#{chapter_lesson_path(@chapter, @lesson)}'>#{@lesson.identifier}</a>".html_safe
    @program_attachments = ProgramAttachment.where(program_id: @chapter.program_id)
  end

  def create

    @lesson = @chapter.lessons.build(lesson_params)
    respond_to do |format|  
      if @lesson.save
        @chapter.lessons << @lesson
        #NewContentNotificationJob.perform_async(@chapter.program,  dashboard_program_url(@chapter.program)) #Se llevó a método program#notify_changes
        #QueueNotification.create(category: 2, program: @chapter.program.id, url: dashboard_program_url(@chapter.program), detail: "up-lesson-#{@lesson.id}")
        format.html {redirect_to content_chapter_path(@chapter), notice: "Se creo exitosamente el contenido #{@lesson.identifier}"}
        format.js{}
      else
        format.html {render :new}
      end
    end  
  end

  def edit
    add_breadcrumb @chapter.program.name, program_path(@chapter.program)
    add_breadcrumb @lesson.identifier, chapter_lesson_path(@chapter, @lesson)
    add_breadcrumb "<a class='active' href='#{edit_chapter_lesson_path(@chapter, @lesson)}'>Editar contenido</a>".html_safe
    @program_attachments = ProgramAttachment.where(program_id: @chapter.program_id)
  end

  def update

    respond_to do |format|  
      if @lesson.update_attributes(lesson_params)
        #QueueNotification.create(category: 3, program: @chapter.program.id, url: dashboard_program_url(@chapter.program), detail: "edit-lesson-#{@lesson.id}")
        format.html {redirect_to content_chapter_path(@chapter), notice: "Se actualizó exitosamente el contenido #{@lesson.identifier}"}
        format.js {}
      else
        format.html {render :edit}
      end
    end
  end

  def destroy
    capitulo = @lesson.chapter_content.chapter
    if capitulo.program.nil?
      content = capitulo.get_cc_chapter.id
    else
      content = nil
    end    
    ActiveRecord::Base.transaction do
      ChapterContent.where({coursable_type: 'Lesson', coursable_id: @lesson.id}).delete_all
      @lesson.destroy
      chapter_contents = @chapter.chapter_contents.map{ |cp| cp.id }
      chapter_contents.each_with_index do |id, index|
        ChapterContent.find(id).update_attributes({position: index + 1})
      end
    end
=begin
    up_notification = QueueNotification.find_by(category: 2, detail: "up-lesson-#{@lesson.id}", sent: false)
    if !up_notification.nil?
      up_notification.destroy
    else
      QueueNotification.create(category: 2, program: @chapter.program.id, url: dashboard_program_url(@chapter.program), detail: "down-lesson-#{@lesson.id}")
    end
=end    
    flash[:id_aux] = content
    redirect_to :back, notice: "Se eliminó exitosamente el contenido #{@lesson.identifier}"
  end

  def clone
    capitulo = @lesson.chapter_content.chapter
    if capitulo.program.nil?
      content = capitulo.get_cc_chapter.id
    else
      content = nil
    end 

    lesson_clone = @lesson.deep_clone

    @chapter.lessons << lesson_clone

    flash[:id_aux] = content
    redirect_to :back, notice: "Se creo exitosamente el contenido #{@lesson.identifier}"
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
