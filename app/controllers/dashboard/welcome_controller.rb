class Dashboard::WelcomeController < ApplicationController
  before_action :authenticate_user!
  after_action :change_video_trigger, only: [:learning_path]

  helper_method :last_moved_program
  helper_method :last_visited_content
  add_breadcrumb "EDCDIGITAL", :root_path

  def index
    add_breadcrumb "<a class='active' href='#{root_path}'>Inicio</a>".html_safe
  end

  def terms
    add_breadcrumb "<a class='active' href='#{dashboard_terms_path}'>TÉRMINOS DE SERVICIO</a>".html_safe
  end

  def privacy
    add_breadcrumb "<a class='active' href='#{dashboard_privacy_path}'>POLÍTICA DE PRIVACIDAD</a>".html_safe
  end

  def support
    add_breadcrumb "<a class='active' href='#{dashboard_support_path}'>Ayuda</a>".html_safe
    last_program = current_user.get_last_program
    last_tracker = last_program.get_last_move(current_user)
    last_chapter = last_tracker.chapter_content.chapter
    last_content = last_tracker.chapter_content
    if last_content.coursable_type == "Lesson"
        last_content_title = last_content.model.identifier
      else
        last_content_title = last_content.model.question_text
    end
    @last_content_address = "Programa: #{last_program.name} / Módulo: #{last_chapter.name} / Contenido: #{last_content_title}"
  end

  def service
    add_breadcrumb "<a class='active' href='#{dashboard_support_path}'>TÉRMINOS DE SERVICIO</a>".html_safe
  end

  def pathway
    add_breadcrumb "<a class='active' href='#{dashboard_pathway_path}'>Mi ruta de emprendimiento</a>".html_safe
    @last_text = RouteText.last
    @last_cover = RouteCover.last
    @texts = RouteText.all
    @covers = RouteCover.all
  end

  def learning_path
    ids=current_user.group.programs.ruta.map{|p|p.id}
    @group_programs=current_user.group.group_programs.where(program_id: ids).order(:position)
    c=0 
    ids=[]
    @group_programs.each do |p|
      c+=1
      anterior = p.anterior(current_user.group)
      if current_user.percentage_questions_answered_for(anterior)>80 || c==1 
        ids.push(p.id)
      else
        break
      end
    end
    @group_programs=GroupProgram.where(id: ids).order(:position)     
    @modal_trigger = current_user.video_trigger
  end  
 
  def send_support_email

    if params[:raw_subject].present? == false || params[:message].present? == false
      flash_message = { alert: 'No olvides escribir asunto y mensaje.'}
    elsif params[:urgency] == 'none' || params[:matter] == 'none'
      flash_message = { alert: 'Recuerda seleccionar urgencia y clasificación.'}
    else
      MentorHelp.create
      unless params[:file].nil?
        uploaded_io=params[:file][:attachment]
        p uploaded_io.content_type
      end   
      chapter = "Sección de ayuda (<a class='active' href='https://www.edcdigital.mx/dashboard/ayuda'>puedes verla aquí</a>)".html_safe
      @recipients = [{adress: 'soporte@edc-digital.com', type: 'soporte'}, {adress: current_user.email, type: 'usuario'}]
      @recipients.each do |recipient, index|
        if recipient[:type] == 'soporte'
          subject = "Solicitud de soporte EDC-Digital: " + params[:raw_subject]
          Support.contact(subject, params[:message], params[:urgency], params[:matter], current_user, chapter, params[:signature], recipient[:adress], params[:program], params[:last_content], uploaded_io).deliver_now
          flash_message = { notice: 'Su mensaje ha sido enviado.'}
        else
          subject = "Recibimos tu mensaje: " + params[:raw_subject]
          Support.notify(subject, params[:raw_subject], params[:message], params[:urgency], params[:matter], current_user, chapter, params[:signature], recipient[:adress],uploaded_io).deliver_now
          flash_message = { notice: 'Su mensaje ha sido enviado.'}
        end
      end
    end

    redirect_to dashboard_support_path, flash_message
  end

  def calculator
    add_breadcrumb "<a class='active' href='#{dashboard_calculator_path}'>Calculadora de tamaño de muestra</a>".html_safe
    
    if !params[:param_result].nil?
      @sample_size, @eighty_s, @innovators_s, @eighty_s_innovators, @inn_early_s  = params[:param_result][0], params[:param_result][1], params[:param_result][2], params[:param_result][3], params[:param_result][4]
      @eighty_s_y, @innovators_n, @eighty_n, @inn_early_n, @eighty_n_y, @population = params[:param_result][5], params[:param_result][6], params[:param_result][7], params[:param_result][8], params[:param_result][9], params[:param_result][10]
    end
  end

  def calculator_method
    population = params[:calculator][:population].to_f
    truster, success, failure, presicion, z, early, innovators = 0.95, 0.5, 0.5, 0.05, 1.96, 0.135, 0.025

    sample_size = (z**2 * success * failure * population) / ((population * presicion**2) + (z**2 * success * failure))
    eighty_s = sample_size * 0.8
    innovators_s = sample_size * innovators
    eighty_s_innovators = innovators_s * 0.8
    inn_early_s = (sample_size * early) + (sample_size * innovators)
    eighty_s_y = inn_early_s * 0.8
    innovators_n = population * innovators
    eighty_n = innovators_n * 0.8
    inn_early_n = (early + innovators) * population
    eighty_n_y = inn_early_n * 0.8

    redirect_to dashboard_calculator_path(:param_result => [sample_size, eighty_s, innovators_s, eighty_s_innovators, inn_early_s, eighty_s_y, innovators_n, eighty_n, inn_early_n, eighty_n_y, population])#(:param_result => sample_size)
  end

  def notifications_panel
    add_breadcrumb "<a class='active' href='#{dashboard_notifications_panel_path}'>Panel de notificaciones</a>".html_safe
    @noti=PanelNotification.where(user: current_user)
  end

  def store_notifications_panel
    @notification=PanelNotification.where(user: current_user, notification: params[:notification]).first
    if @notification.nil?
      nt=PanelNotification.create(status: false, user: current_user, notification: params[:notification].to_i)
    else
      @notification.update(status: !@notification.status)
    end  
    render json:{nt: @notification}
  end  

  private
  def change_video_trigger
    if current_user.video_trigger
      current_user.update(video_trigger: false)
    end
  end

  def last_moved_program(program)
     last_moved_content = program.get_last_move(current_user)
    if !last_moved_content.nil?
      last_move = last_moved_content.chapter_content_id
      last_time = last_moved_content.updated_at
      last_content = last_moved_content.chapter_content
      
      if last_content.coursable_type == "Lesson"
        last_text = last_content.model.identifier
      else
        last_text = last_content.model.question_text
      end
    end
    return last_move, last_time, last_content, last_text, last_moved_content
  end

  def last_visited_content(program, stats)
    if stats != nil
      last = ( !stats.last_content.nil? ? stats.last_content : nil)
      return last
    else
      return nil
    end
  end

end
