class ChaptersController < ApplicationController
  require 'json'
  before_action :authenticate_user!
  before_action :set_program, except: [:content, :rubrics]
  before_action :set_chapter, only: [:edit, :update, :destroy, :clone, :content, :rubrics]
  before_action :require_admin

  add_breadcrumb "EDC DIGITAL", :root_path
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
      QueueNotification.create(category: 0, program: @chapter.program.id, url: dashboard_program_url(@chapter.program), detail: "up-chapter-#{@chapter.id}")
      redirect_to @program, notice: "Se creo exitosamente el módulo #{@chapter.name}"
    else
      render :new
    end
  end

  def edit
    add_breadcrumb @program.name, program_path(@program)
    add_breadcrumb "<a class='active' href='#{edit_program_chapter_path(@program, @chapter)}'>#{@chapter.name}</a>".html_safe
  end

  def update
    add_breadcrumb @program.name, program_path(@program)
    add_breadcrumb "<a class='active' href='#{program_chapter_path(@program, @chapter)}'>#{@chapter.name}</a>".html_safe

    if @chapter.update(chapter_params)
      QueueNotification.create(category: 1, program: @chapter.program.id, url: dashboard_program_url(@chapter.program), detail: "edit-chapter-#{@chapter.id}")
      redirect_to @program, notice: "Se actualizó exitosamente el módulo #{@chapter.name}"
    else
      render :edit
    end
  end

  def destroy
     @chapter.destroy
     up_notification = QueueNotification.find_by(category: 0, detail: "up-chapter-#{@chapter.id}", sent: false)
     if !up_notification.nil?
       up_notification.destroy
     else
       QueueNotification.create(category: 0, program: @chapter.program.id, url: dashboard_program_url(@chapter.program), detail: "down-chapter-#{@chapter.id}")
     end

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

      elsif model.is_a?(Chapter)

        content_clone =  model.deep_clone do |original, kopy|
          kopy.name = "#{original.name} copia"
        end
        model.chapter_contents.each do |chapter_content|
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
        clone_chapter.content_chapters << content_clone

      end
    end

    clone_chapter.save

    redirect_to @program, notice: "Se creo exitosamente el módulo #{clone_chapter.name}"
  end

  def content
    program = @chapter.program
    add_breadcrumb "<a href='#{program_path(program)}'>#{program.name}</a>".html_safe
    add_breadcrumb "<a class='active' href='#{content_chapter_path(@chapter)}'>#{@chapter.name}</a>".html_safe
    @lesson=Lesson.new
    @question=Question.new
  end

  def rubrics
    @program = @chapter.program
    add_breadcrumb "<a href='#{program_path(@program)}'>#{@program.name}</a>".html_safe
    add_breadcrumb "<a class='active' href='#{rubrics_chapter_path(@chapter)}'>#{@chapter.name}</a>".html_safe
    
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
