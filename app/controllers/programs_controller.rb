class ProgramsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin
  before_action :set_program, only: [:show, :edit, :update, :destroy, :clone, :notify_changes, :notify_null]
  before_action :set_pending_content_notifications, only: [:show, :notify_changes, :notify_null]

  add_breadcrumb (ENV['COMPANY_NAME'].nil? ? "Inicio" : ENV['COMPANY_NAME']), :root_path

  def index
    add_breadcrumb "<a class='active' href='#{programs_path}'>Programas</a>".html_safe

    @programs = Program.all.order(position: :asc)
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
      NewProgramNotificationProgJob.perform_async(@program, dashboard_program_url(@program))
      redirect_to @program, notice: "Se creo exitosamente el programa #{@program.name}"
    else
      render :new
    end
  end

  def edit
    add_breadcrumb "Programas", :programs_path
    add_breadcrumb "<a class='active' href='#{edit_program_path(@program)}'>#{@program.name}</a>".html_safe
  end

  def update
    groups=[]
    add_breadcrumb "Programas", :programs_path
    add_breadcrumb "<a class='active' href='#{edit_program_path(@program)}'>#{@program.name}</a>".html_safe
    before = @program.groups.map{|g| g.id}
    if @program.update(program_params)
      after = @program.groups.map{|g| g.id}
      after.each do |g|
        unless before.include?(g)
          groups.push(g)
        end  
      end
      NewProgramNotificationEditJob.perform_async(Group.where(id: groups), @program, dashboard_program_url(@program)) 
      redirect_to edit_program_path, notice: "Se actualizó exitosamente el programa #{@program.name}"
    else
      render :edit
    end
  end

  def destroy
     @program.destroy

     redirect_to programs_path, notice: "Se eliminó exitosamente el programa #{@program.name}"
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

    redirect_to programs_path, notice: "Se creo exitosamente el programa #{program.name}"
  end

  def sort
    params[:program].each_with_index do |id, index|
      Program.find(id).update_attributes({position: index + 1})
    end

    render nothing: true
  end

  def notify_changes
    @pending_content_notifications.map{|queue| queue.update(sent: true)}
    NewContentNotificationJob.perform_async(@program, dashboard_program_url(@program))
    redirect_to program_path(@program), notice: "Se notificó el cambio sobre el programa #{@program.name}"
  end

  def notify_null
    @pending_content_notifications.delete_all
    redirect_to program_path(@program), notice: "Se eliminaron las notificaciones pendientes"
  end

  private
  def program_params
    params.require(:program).permit(:name, :short_name, :description, :cover, :small_cover, :category, :objetive, :curriculum, :icon, :video, :color, :tipo, :level, :content_type, group_ids: [])
  end

  def set_program
    @program = Program.find(params[:id])
  end

  def set_pending_content_notifications
    @pending_content_notifications = QueueNotification.where(program: @program.id, category: [0, 1, 2, 3], sent: false)
  end
end
