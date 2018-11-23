class QuestionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_chapter
  before_action :set_question, only: [:edit, :update, :destroy, :clone]
  before_action :require_admin  
  add_breadcrumb (ENV['COMPANY_NAME'].nil? ? "Inicio" : ENV['COMPANY_NAME']), :root_path
  add_breadcrumb "Programas", :programs_path

  def new
    add_breadcrumb @chapter.program.name, program_path(@chapter.program)
    add_breadcrumb "<a class='active' href='#{new_chapter_question_path(@chapter)}'>Nueva pregunta</a>".html_safe

    @question = @chapter.questions.new
    ['Deficiente', 'Regular', 'Bueno', 'Excelente'].each do |criteria|
      @question.rubrics.new({criteria: criteria})
    end
  end

  def create

    @question = @chapter.questions.build(question_params)
    respond_to do |format|  
      if @question.save
        @chapter.questions << @question
        if (@chapter.points.nil? || @chapter.manual_points == false)
          @chapter.set_chapters_points
        end
        #NewContentNotificationJob.perform_async(@chapter.program, dashboard_program_url(@chapter.program)) #Se llevó a método program#notify_changes
        #QueueNotification.create(category: 2, program: @chapter.program.id, url: dashboard_program_url(@chapter.program), detail: "up-question-#{@question.id}")
        format.html {redirect_to content_chapter_path(@chapter), notice: "Se creo exitosamente la pregunta #{@question.question_text}"}
        format.js {}
      else
        format.html {render :new}
      end
    end  
  end

  def edit
    add_breadcrumb @chapter.program.name, program_path(@chapter.program)
    add_breadcrumb "<a class='active' href='#{edit_chapter_question_path(@chapter, @question)}'>#{@question.question_text}</a>".html_safe
  end

  def update
    
    respond_to do |format|
      if @question.update_attributes(question_params)
        #QueueNotification.create(category: 3, program: @chapter.program.id, url: dashboard_program_url(@chapter.program), detail: "edit-question-#{@question.id}")
        format.html {redirect_to content_chapter_path(@chapter), notice: "Se actualizó exitosamente la pregunta  #{@question.question_text}"}
        format.js {}
      else
        format.html {render :edit}
      end
    end
  end

  def destroy
    capitulo = @question.chapter_content.chapter
    if capitulo.program.nil?
      content = capitulo.get_cc_chapter.id
    else
      content = nil
    end  
    ActiveRecord::Base.transaction do
      ChapterContent.where({coursable_type: 'Question', coursable_id: @question.id}).delete_all
      @question.destroy
      chapter_contents = @chapter.chapter_contents.map{ |cp| cp.id }
      chapter_contents.each_with_index do |id, index|
        ChapterContent.find(id).update_attributes({position: index + 1})
      end
    end
    # Recalcular 'points' de los chapters del programa - START
    capitulo.set_chapters_points
    if capitulo.chapter_contents.where(coursable_type: "Question").empty?
      capitulo.update(points: 0, manual_points: false)
      capitulo.set_chapters_points
    end
    # Recalcular 'points' de los chapters del programa - END
=begin
    up_notification = QueueNotification.find_by(category: 2, detail: "up-question-#{@question.id}", sent: false)
    if !up_notification.nil?
      up_notification.destroy
    else
      QueueNotification.create(category: 2, program: @chapter.program.id, url: dashboard_program_url(@chapter.program), detail: "down-question-#{@question.id}")
    end
=end    
    flash[:id_aux] = content
    redirect_to :back, notice: "Se eliminó exitosamente la pregunta #{@question.question_text}"
  end

  def clone
    capitulo = @question.chapter_content.chapter
    if capitulo.program.nil?
      content = capitulo.get_cc_chapter.id
    else
      content = nil
    end 

    question_clone =  @question.deep_clone do |original, kopy|
      kopy.question_text = "#{original.question_text} copia"
      kopy.support_image = original.support_image
      kopy.rubrics = original.rubrics.map(&:deep_clone)
    end

    @chapter.questions << question_clone
    flash[:id_aux] = content
    redirect_to :back, notice: "Se creo exitosamente la pregunta #{question_clone.question_text}"
  end

  private
  def question_params
    params.require(:question)
      .permit(:question_type, :question_text, :position, :answer_options,
              :support_text, :support_image, :points, rubrics_attributes: [:id, :criteria, :base])
  end

  def set_chapter
    @chapter = Chapter.find(params[:chapter_id])
  end

  def set_question
    @question = Question.find(params[:id])
  end
end
