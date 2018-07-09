class Dashboard::WelcomeController < ApplicationController
  before_action :authenticate_user!, except: [:privacy_noregister]
  before_action :redirect_to_support, if: :student_have_group? , only: [:support, :send_support_email, :learning_path]
  before_action :redirect_to_learning, if: :have_group?, only: [:contact_admin, :contact_admin_mail]
  after_action :change_video_trigger, only: [:learning_path]

  helper_method :last_moved_program
  helper_method :last_visited_content
  add_breadcrumb "EDC DIGITAL", :root_path, except: [:privacy_noregister]
  include EvaluationRefilablesHelper

  def index
    add_breadcrumb "<a class='active' href='#{root_path}'>Inicio</a>".html_safe
  end

  def terms
    add_breadcrumb "<a class='active' href='#{dashboard_terms_path}'>TÉRMINOS DE SERVICIO</a>".html_safe
  end

  def privacy
    add_breadcrumb "<a class='active' href='#{dashboard_privacy_path}'>POLÍTICA DE PRIVACIDAD</a>".html_safe
  end

  def privacy_noregister
    render layout: "layouts/politicas"
  end

  def support
    add_breadcrumb "<a class='active' href='#{dashboard_support_path}'>Ayuda</a>".html_safe
    if ProgramStat.where(user_id: current_user.id).count != 0
      last_program = current_user.get_last_program
      last_tracker = last_program.nil? ? nil : last_program.get_last_move(current_user)
      last_content = last_tracker.nil? ? nil : last_tracker.chapter_content
      last_chapter = last_content.nil? ? nil : last_content.chapter
      if last_content.nil?
        last_content_title = nil 
      else
        last_content_title = (last_content.coursable_type == "Lesson") ? last_content.model.identifier : last_content.model.question_text
      end
      @last_content_address = "Programa: #{last_program.nil? ? 'N/A' : last_program.name} / Módulo: #{last_chapter.nil? ? 'N/A' : last_chapter.name} / Contenido: #{last_content_title.nil? ? 'N/A' : last_content_title}"
    else
      @last_content_address = "Programa: N/A / Módulo: N/A / Contenido: N/A"
    end  
  end

  def service
    add_breadcrumb "<a class='active' href='#{dashboard_service_path}'>TÉRMINOS DE SERVICIO</a>".html_safe
  end

  def pathway
    add_breadcrumb "<a class='active' href='#{dashboard_pathway_path}'>Fases de una idea viable</a>".html_safe
    @last_text = RouteText.last
    @last_cover = RouteCover.last
    @texts = RouteText.all
    @covers = RouteCover.all
  end

  def learning_path
    add_breadcrumb "<a class='active' href='#{dashboard_learning_path_path}'>Mi ruta de aprendizaje</a>".html_safe
    @programs_fisica=current_user.group.learning_path.learning_path_contents.where(content_type: "Program").order(:position) rescue nil
    c=0
    @c1=0
    ids=[]
    unless @programs_fisica.nil?
      @programs_fisica.each do |p|
        c+=1
        anterior = p.anterior(current_user.group.learning_path)
        if current_user.percentage_questions_answered_for(anterior) >= 1 || c==1 || (current_user.percentage_content_visited_for(anterior) >= 60 && anterior.questions? == false)
          ids.push(p.id)
        else
          break
        end
      end
      @programs_fisica=LearningPathContent.where(id: ids).order(:position)
      
      
    end
    
    @programs_moral=current_user.group.learning_path2.learning_path_contents.where(content_type: "Program").order(:position) rescue nil
    c=0
    @c2=0
    ids=[]
    unless @programs_moral.nil?
      @programs_moral.each do |p|
        c+=1
        anterior = p.anterior(current_user.group.learning_path2)
        if current_user.percentage_questions_answered_for(anterior) >= 1 || c==1 || (current_user.percentage_content_visited_for(anterior) >= 60 && anterior.questions? == false)
          ids.push(p.id)
        else
          break
        end
      end
      @programs_moral=LearningPathContent.where(id: ids).order(:position)
    end
    ####### Fisica Quizzes y Refilables
    @pf_complementaries = []
    unless @programs_fisica.nil?     
      @programs_fisica.each do |pf|
        program = pf.model
        program.quizzes.each do |pf_quiz|
          promedio = pf_quiz.promedio(current_user)
          if pf_quiz.answered?(current_user) && promedio < 80
            @pf_complementaries << {program: program.id, content_name: pf_quiz.name, content_type: "Quiz", avg: promedio, url: apply_dashboard_quiz_path(pf_quiz, user_id: current_user.id)}
          end
        end
        program.template_refilables.each do |pf_t_refil|
          ########## Calculos ###########
          refilable_user = pf_t_refil.refilables.where(user: @user).order(:created_at).last
          c_rubrics = pf_t_refil.evaluation_refilables.count
          ids_rubricas = pf_t_refil.evaluation_refilables.pluck(:id)
          c_user_evaluation =  UserEvaluationRefilable.where(evaluation_refilable_id: ids_rubricas, user_id: current_user.id).count 
          promedio = user_promedio_refilable(pf_t_refil.puntaje(current_user, refilable_user), pf_t_refil.total_points)
          ###########         ########### 
          if !refilable_user.nil? && (c_rubrics == c_user_evaluation && c_rubrics > 0) && promedio < 80
            @pf_complementaries << {program: program.id, content_name: pf_t_refil.name, content_type: "TemplateRefilable", avg: promedio, url: edit_dashboard_template_refilable_refilable_path(pf_t_refil, refilable_user)}
          end
        end 
      end
    end   
    ####### Moral Quizzes y Refilables
    @pm_complementaries = []
    unless @programs_moral.nil?
      @programs_moral.each do |pm|
        program = pm.model
        program.quizzes.each do |pm_quiz|
          promedio = pm_quiz.promedio(current_user)
          if pm_quiz.answered?(current_user) && promedio < 80
            @pm_complementaries << {program: program.id, content_name: pm_quiz.name, content_type: "Quiz", avg: promedio, url: apply_dashboard_quiz_path(pm_quiz, user_id: current_user.id)}
          end
        end
        program.template_refilables.each do |pm_t_refil|
          ########## Calculos ###########
          refilable_user = pm_t_refil.refilables.where(user: @user).order(:created_at).last
          c_rubrics = pm_t_refil.evaluation_refilables.count
          ids_rubricas = pm_t_refil.evaluation_refilables.pluck(:id)
          c_user_evaluation =  UserEvaluationRefilable.where(evaluation_refilable_id: ids_rubricas, user_id: current_user.id).count 
          promedio = user_promedio_refilable(pm_t_refil.puntaje(current_user, refilable_user), pm_t_refil.total_points)
          ###########         ########### 
          if !refilable_user.nil? && (c_rubrics == c_user_evaluation && c_rubrics > 0) && promedio < 80
            @pm_complementaries << {program: program.id, content_name: pm_t_refil.name, content_type: "TemplateRefilable", avg: promedio, url: edit_dashboard_template_refilable_refilable_path(pm_t_refil, refilable_user)}
          end
        end 
      end
    end    
    @modal_trigger = current_user.video_trigger
    @tour_trigger = current_user.tour_trigger

    #render :json => {1=> @pf_complementaries , 2 => @pm_complementaries}
  end

  def send_support_email

    if params[:raw_subject].present? == false || params[:message].present? == false
      flash_message = { alert: 'No olvides escribir asunto y mensaje.'}
    elsif params[:urgency] == 'none' || params[:matter] == 'none'
      flash_message = { alert: 'Recuerda seleccionar urgencia y clasificación.'}
    else
      MentorHelp.create(sender: current_user.id)
      unless params[:file].nil?
        uploaded_io=params[:file][:attachment]
        p uploaded_io.content_type
      end
      chapter = "Sección de ayuda (<a class='active' href='https://www.edcdigital.mx/dashboard/ayuda'>puedes verla aquí</a>)".html_safe
      @recipients = [{adress: 'soporte2@edc-digital.com', type: 'soporte'}, {adress: current_user.email, type: 'usuario'}]
      @recipients.each do |recipient, index|
        if recipient[:type] == 'soporte'
          subject = "Solicitud de soporte EDC Digital: " + params[:raw_subject]
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
      @notification=PanelNotification.create(status: false, user: current_user, notification: params[:notification].to_i)
    else
      @notification.update(status: !@notification.status)
    end
    render json:{nt: @notification}
  end

  def contact_admin
    @state = State.all
  end

  def contact_admin_mail
    if params[:state].present? == false 
      flash_message = { alert: 'No olvides agregar el estado.'}
    else
      @user = User.find(params[:user])
      state = State.find(params[:state])
      @user.update(group_id: 36)
      Support.sin_grupo(@user, state, params[:university], user_url(@user), @user.group)
    end
    redirect_to dashboard_learning_path_path  
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
