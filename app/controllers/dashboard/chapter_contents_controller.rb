class Dashboard::ChapterContentsController < ApplicationController
  before_action :authenticate_user!
  before_action :redirect_to_support, if: :student_have_group?
  before_action :track_chapter_content, only: [:show]
  before_action :redirect_to_learning_nil, if: :access_deleted_content, only: [:show]
  before_action :redirect_to_learning, if: :permiso_avance, only: [:show]
  after_action :update_program_stats, only: [:show]

  def show
    @tour_trigger = current_user.tour_trigger
    rank = Rating.where(ratingable_type: "ChapterContent", ratingable_id: @chapter_content.id, user_id: current_user.id).first
    if rank.nil?
      @rank=0
    else
      @rank=rank.rank
    end  
    if @chapter_content.coursable_type == 'Question' 
      redirect_to router_dashboard_chapter_content_answers_path(@chapter_content), status: 301    
    elsif @chapter_content.coursable_type == 'Chapter'
      redirect_to  router_dashboard_chapter_content_contents_path(@chapter_content)    
    else
      add_breadcrumb (ENV['COMPANY_NAME'].nil? ? "Inicio" : ENV['COMPANY_NAME']), :root_path
      add_breadcrumb @chapter_content.chapter.program.name, dashboard_program_path(@chapter_content.chapter.program)
      add_breadcrumb "<a class='active' href='#{dashboard_chapter_content_path(@chapter_content)}'>#{@chapter_content.model.identifier}</a>".html_safe
    end 
  end

  #Nuevo: datos para el correo
  def mailer_interno
    if params[:raw_subject].present? == false || params[:message].present? == false
      flash_message = { alert: 'ERROR: No olvides escribir asunto y mensaje.'}
    elsif params[:urgency] == 'none' || params[:matter] == 'none'
      flash_message = { alert: 'ERROR: Recuerda seleccionar nivel de urgencia y clasificación.'}
    else
      @recipients = [{adress: (ENV['MAILER_SUPPORT'].nil? ? "soporte@ejemplo.com" : ENV['MAILER_SUPPORT']), type: 'soporte'}, {adress: current_user.email, type: 'usuario'}]
      @recipients.each do |recipient, index|
        if recipient[:type] == 'soporte'
          subject = "Solicitud de soporte: " + params[:raw_subject]
          Support.contact(subject, params[:message], params[:urgency], params[:matter], current_user, params[:chapter], params[:signature], recipient[:adress], params[:signature], params[:chapter], nil).deliver_now
          flash_message = { notice: 'Su mensaje ha sido enviado.'}
        else
          subject = "Recibimos tu mensaje: " + params[:raw_subject]
          Support.notify(subject, params[:raw_subject], params[:message], params[:urgency], params[:matter], current_user, params[:chapter],params[:signature], recipient[:adress], nil).deliver_now
          flash_message = { notice: 'Su mensaje ha sido enviado.'}
        end
      end
    end

    redirect_to router_dashboard_chapter_content_answers_path, flash_message
  end

  private
  def track_chapter_content
    if ChapterContent.exists?(id: params[:id])
      @chapter_content = ChapterContent.find(params[:id])
      if Tracker.find_by(chapter_content: @chapter_content, user: current_user).nil?
        Tracker.create(chapter_content: @chapter_content, user: current_user)
      else
        Tracker.find_by(chapter_content: @chapter_content, user: current_user).touch
      end

      ahoy.track "Viewed content", chapter_content_id: @chapter_content.id
    else
      @chapter_content = nil
      ahoy.track "Viewed content", chapter_content_id: nil
    end
  end

  def access_deleted_content
    @chapter_content.nil?
  end 

  def permiso_avance
    permiso_programs(@chapter_content.chapter.program, current_user)
  end 

  def update_program_stats
    #program = Program.joins(:chapters => :chapter_contents).where(chapter_contents: {id: @chapter_content.id}).last
    program = @chapter_content.chapter.program
    program_stat = ProgramStat.find_by(user_id: @current_user.id, program_id: program.id)
    prog_progress = @current_user.percentage_questions_answered_for(program)
    prog_seen = @current_user.percentage_content_visited_for(program)
    last_cont = program.get_last_move(@current_user).chapter_content.id

    if program_stat.nil?
      new_stat = ProgramStat.create(user_id: @current_user.id, program_id: program.id, program_progress: prog_progress, program_seen: prog_seen, last_content: last_cont)
    else
      if prog_progress == program_stat.program_progress && prog_seen == program_stat.program_seen && last_cont == program_stat.last_content
        program_stat.touch
      else
        program_stat.update(program_progress: prog_progress, program_seen: prog_seen, last_content: last_cont)
      end
    end

    student_progress = @current_user.answered_questions_percentage
    student_seen = @current_user.content_visited_percentage
    @current_user.update(user_progress: student_progress, user_seen: student_seen)
  end
end
