class Dashboard::RefilableProgramsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_chapter_content
  after_action :update_program_stats, only: [:create, :update]

  add_breadcrumb "EDCDIGITAL", :root_path
  add_breadcrumb "programas", :dashboard_programs_path


  def router
    refilable=@chapter_content.model.refilables.find_by(user: current_user)
    if @chapter_content.model.refilables.find_by(user: current_user).nil?
      redirect_to new_dashboard_chapter_content_refilable_program_path(@chapter_content)
    else
      redirect_to dashboard_chapter_content_refilable_program_path(@chapter_content, refilable)
    end
  end
  def new
    @refilable=Refilable.new()
    @template=@chapter_content.model
    add_breadcrumb @chapter_content.chapter.program.name, dashboard_program_path(@chapter_content.chapter.program)
    add_breadcrumb "<a class='active' href='#{dashboard_chapter_content_path(@chapter_content)}'>#{@chapter_content.model.name}</a>".html_safe
  end
  def create
    @template=@chapter_content.model
    refilable = @template.refilables.new(refilable_params)
    refilable.user = current_user
    refilable.save

    redirect_to_next_content    
  end

  def show
    @refilable=@chapter_content.model.refilables.find_by(user: current_user)
    add_breadcrumb @chapter_content.chapter.program.name, dashboard_program_path(@chapter_content.chapter.program)
    add_breadcrumb "<a class='active' href='#{dashboard_chapter_content_path(@chapter_content)}'>#{@chapter_content.model.name}</a>".html_safe
  end

  def edit 
    @template=@chapter_content.model
    @refilable=@chapter_content.model.refilables.find_by(user: current_user)
    add_breadcrumb @chapter_content.chapter.program.name, dashboard_program_path(@chapter_content.chapter.program)
    add_breadcrumb "<a class='active' href='#{dashboard_chapter_content_path(@chapter_content)}'>#{@chapter_content.model.name}</a>".html_safe
  end

  def update
    @refilable = Refilable.find(params[:id])

    @refilable.update(refilable_params)

    redirect_to_next_content 
  end  

  private
  def set_chapter_content
    @chapter_content = ChapterContent.find(params[:chapter_content_id])
  end
  def refilable_params
    params.permit(:content)
  end
  def redirect_to_next_content
    program=@chapter_content.chapter.program
    mensaje= "Plantilla guardada con éxito"

    if current_user.percentage_answered_for(program)>80 && current_user.percentage_answered_for(program)<100
      if current_user.program_notifications.where(program: program).more80.first.nil?
        current_user.program_notifications.create(program: program, notification_type: 'more80')
        if current_user.panel_notifications.more80_student.first.nil? || current_user.panel_notifications.more80_student.first.status
          Programs.more80_student(program, current_user, dashboard_program_url(program))
        end
        #soporte
        soporte=User.new(email: "soporte@edc-digital.com")
        Programs.more80_mentor(program,soporte,current_user,user_url(current_user))
        if program.ruta?
          flash[:more80]="Haz completado el 80% del curso, pronto desbloquearas el siguiente contenido!"
        else
          flash[:more80]="Haz completado el 80% del curso!"
        end    
        #mentores
        ProgramMore80NotificationJob.perform_async(program,current_user,mentor_student_url(current_user))
      end
      if program.ruta?
        mensaje = mensaje + ", haz completado el #{current_user.percentage_answered_for(program)}\% del programa, ya mero entras al siguiente curso."
      else
        mensaje = mensaje + ", haz completado el #{current_user.percentage_answered_for(program)}\% del programa."
      end  
    elsif current_user.percentage_answered_for(program)==100
      if current_user.program_notifications.where(program: program).complete.first.nil?
        current_user.program_notifications.create(program: program, notification_type: 'complete')
        if current_user.panel_notifications.complete_student.first.nil? || current_user.panel_notifications.complete_student.first.status
          Programs.complete_student(program, current_user, dashboard_program_url(program))
        end
        #soporte
        soporte=User.new(email: "soporte@edc-digital.com")
        Programs.complete_mentor(program,soporte,current_user,user_url(current_user))
        flash[:complete]="Haz completado el curso!"
        #mentores
        ProgramCompleteNotificationJob.perform_async(program,current_user,mentor_student_url(current_user))
      end
      if program.ruta?  
        mensaje = mensaje + ", haz completado el 100% del curso, se ha desbloqueado un nuevo contenido."
      else
        mensaje = mensaje + ", haz completado el 100% del curso."
      end      
    end

    if @chapter_content.lower_item
      redirect_to dashboard_chapter_content_path(@chapter_content.lower_item), notice: mensaje
    elsif program.next_chapter(@chapter_content.chapter) && program.next_chapter(@chapter_content.chapter).chapter_contents.first
      redirect_to dashboard_chapter_content_path(program.next_chapter(@chapter_content.chapter).chapter_contents.first), notice: mensaje
    else
      redirect_to dashboard_program_path(program), notice: mensaje
    end
  end

  def update_program_stats
    #program = Program.joins(:chapters => :chapter_contents).where(chapter_contents: {id: @chapter_content.id}).last
    program = @chapter_content.chapter.program
    program_stat = ProgramStat.where(user_id: @current_user.id, program_id: program.id).last
    progress = @current_user.percentage_answered_for(program)
    seen = @current_user.percentage_content_visited_for(program)

    if program_stat.nil?
      new_stat = ProgramStat.create(user_id: @current_user.id, program_id: program.id, program_progress: progress, program_seen: seen)
    else
      program_stat.update(program_progress: progress, program_seen: seen)
    end
  end  
end
