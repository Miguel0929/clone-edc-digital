class ContentsChaptersController < ApplicationController
	before_action :authenticate_user!
	before_action :require_admin
	before_action :set_chapter
  before_action :set_chapter_content_contents, only: [:update, :destroy, :clone]
  
  add_breadcrumb "EDC DIGITAL", :root_path
  add_breadcrumb "Programas", :programs_path
	
	def create
    @content_chapter = @chapter.content_chapters.new(name: content_params[:name])

    if @content_chapter.save
    	@chapter.content_chapters << @content_chapter 
      #QueueNotification.create(category: 2, program: @chapter.program.id, url: dashboard_program_url(@chapter.program), detail: "up-chapter_content-#{@chapter_content.id}")
      redirect_to content_chapter_path(@chapter), notice: "Se creó exitosamente el contenido."
    else
      redirect_to content_chapter_path(@chapter), alert: "No se creó exitosamente el contenido."
    end

	end

  def update
    if @chapter_content_contents.update(name: content_edit_params[:edit_name])
      #QueueNotification.create(category: 2, program: @chapter.program.id, url: dashboard_program_url(@chapter.program), detail: "up-chapter_content-#{@chapter_content.id}")
      redirect_to content_chapter_path(@chapter), notice: "Se actualizó el nombre del contenido exitosamente."
    else
      redirect_to content_chapter_path(@chapter), alert: "No se actualizó el nombre del contenido exitosamente."
    end
  end  

	def destroy
    ActiveRecord::Base.transaction do
      ChapterContent.where({coursable_type: 'Chapter', coursable_id: @chapter_content_contents.id}).delete_all
      @chapter_content_contents.destroy
      chapter_contents = @chapter.chapter_contents.map{ |cp| cp.id }
      chapter_contents.each_with_index do |id, index|
        ChapterContent.find(id).update_attributes({position: index + 1})
      end
    end
    redirect_to :back, notice: "Se eliminó exitosamente el contenedor."
	end

  def clone
    content_clone =  @chapter_content_contents.deep_clone do |original, kopy|
      kopy.name = "#{original.name} copia"
    end

    @chapter_content_contents.chapter_contents.each do |chapter_content|
      model = chapter_content.model
      if model.is_a?(Lesson)
        content_clone.lessons << model.deep_clone
      elsif model.is_a?(Question)
        content_clone.questions << model.deep_clone do |original, kopy|
          kopy.support_image = original.support_image
          kopy.rubrics = original.rubrics.map(&:deep_clone)
        end
      end
    end

    content_clone.save
    @chapter.content_chapters << content_clone
    redirect_to :back, notice: "Se creo exitosamente el contenedor"
  end  

	private

  def set_chapter
    @chapter = Chapter.find(params[:chapter_id])
  end

  def set_chapter_content_contents
    @chapter_content_contents = Chapter.find(params[:id])
  end

  def content_params
    params.permit(:name)
  end

  def content_edit_params
    params.permit(:edit_name)
  end   
end
