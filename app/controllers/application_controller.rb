class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  skip_before_filter :verify_authenticity_token, if: -> { controller_name == 'sessions' && action_name == 'create' }
  before_filter :configure_permitted_parameters, if: :devise_controller?
  before_filter :set_breadcrumb, if: :devise_controller?
  before_filter :ban_free_trial
  before_filter :premium?
  before_filter :banned?
  layout :layout_by_resource
  helper_method :xeditable?


  def xeditable? object = nil
    true
  end

  protected
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :phone_number, :email, :industry_id,:password, :password_confirmation, :agreement])
    devise_parameter_sanitizer.for(:accept_invitation).concat [:first_name, :last_name, :phone_number, :agreement, :curp]
    devise_parameter_sanitizer.for(:invite).concat [:role, :group_id]
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :phone_number, :email, :password, :password_confirmation, :gender, :bio, :state, :city, :profile_picture, :industry_id, :curp])
  end

  def ban_free_trial
    if current_user.present? && !current_user.group.nil? && current_user.group.trial
      if (current_user.invitation_accepted_at + 5.days) < Time.now
        user = current_user
        user.premium = false
        user.save
      end  
    end  
  end 

  def premium?
    if current_user.present? && !current_user.premium
      sign_out current_user
      flash[:premium] = "Tu prueba gratis ha vencido. ¿Quieres continuar mejorando tu idea de negocio? Ingresa aquí para obtener tu cuenta <a href='https://www.emprendiendodesdecero.com/edcdigital' target='_blank'>www.emprendiendodesdecero.com/edcdigital</a>"
      redirect_to new_user_session_path
    end
  end 

  def banned?
    if current_user.present? && current_user.banned?
      sign_out current_user
      flash[:alert] = "Lo sentimos tu cuenta ha sido bloqueada por favor comunicate con el administrador para mas informacion"
      redirect_to new_user_session_path
    end
  end

  def xeditable? object = nil
    true
  end

  def require_admin
    redirect_to root_url unless current_user.admin?
  end

  def require_mentor
    redirect_to root_url unless current_user.mentor?
  end

  def require_creator
    redirect_to root_url unless current_user.admin? || current_user.staff?
  end

  def require_profesor
    redirect_to root_url unless current_user.profesor? 
  end

  def require_admin_or_mentor_or_profesor
    redirect_to root_url unless current_user.profesor? || current_user.mentor? || current_user.admin?
  end

  def require_admin_or_mentor
    redirect_to root_url unless current_user.mentor? || current_user.admin?
  end


  def layout_by_resource
    if devise_controller? && resource_name == :user && ((sessions_controller?) || (invitations_controller?) || (registrations_controller?))
      "login"
    elsif devise_controller? && resource_name == :user && controller_name == "passwords"
      'recover_password'
    else
      "application"
    end
  end
=begin
  def permiso_programs(program, user)
   
    if user.mentor? || user.admin?
      return false
    end

    complementarios = user.group.programs_complementaries rescue []
    is_active=true
    if complementarios.include?(program) 
      active=ProgramActive.where(user: user, program: program).first
      if active.nil? then is_active = false else is_active = active.status end  
      if is_active
        return false
      else
        return true
      end
    end   

    user.group.learning_path.nil? ? fisica_programs = [] : fisica_programs = user.group.learning_path.learning_path_contents.where(content_type: "Program").order(:position)
    user.group.learning_path2.nil? ? moral_programs = [] : moral_programs = user.group.learning_path2.learning_path_contents.where(content_type: "Program").order(:position)
    if user.group.all_programs.pluck(:id).include?(program.id)
      primero_fisico = fisica_programs.first.model rescue nil
      primero_moral = moral_programs.first.model rescue nil
      if program == primero_fisico || program == primero_moral
        return false
      else     
        anterior_fisico=Program.new
        fisica_programs.each do |p|
          if p.model==program
            break
          else
            anterior_fisico=p.model
          end
        end
        anterior_moral=Program.new
        moral_programs.each do |p|
          if p.model==program
            break
          else
            anterior_moral=p.model
          end
        end   
        if (user.percentage_answered_for(anterior_fisico) >= 95) || (user.percentage_answered_for(anterior_moral) >= 95 || (user.percentage_content_visited_for(anterior_fisico) == 100 && anterior_fisico.questions? == false) || (user.percentage_content_visited_for(anterior_moral) == 100 && anterior_moral.questions? == false))
          return false
        elsif anterior_fisico.id.nil? || anterior_fisico.id.nil?
          return false 
        elsif (user.percentage_answered_for(anterior_fisico) < 95) && (user.percentage_answered_for(anterior_moral) < 95)  
          return true
        end  
      end
    else 
      return true  
    end  
  end
=end
  def permiso_programs(program, user)
    if user.mentor? || user.profesor? || user.admin?
      return false
    elsif user.student?
      complementarios = user.group.programs_complementaries rescue []
      is_active = true
      if complementarios.include?(program) 
        active=ProgramActive.where(user: user, program: program).first
        if active.nil? then is_active = false else is_active = active.status end  
        if is_active
          return false
        else
          return true
        end
      end
      user.group.learning_path.nil? ? fisica_programs = [] : fisica_programs = user.group.learning_path.learning_path_contents.where(content_type: "Program").order(:position).pluck(:content_id)
      user.group.learning_path2.nil? ? moral_programs = [] : moral_programs = user.group.learning_path2.learning_path_contents.where(content_type: "Program").order(:position).pluck(:content_id)
      if fisica_programs.include?(program.id) || moral_programs.include?(program.id)
        return false
      else
        return true
      end  
    end
  end  

  def student_have_group?
    if current_user.student? && current_user.group.nil?
      return true
    else
      return false
    end  
  end

  def have_group?
    if current_user.student? && !current_user.group.nil?
      return true
    else
      return false
    end  
  end

  def redirect_to_learning
    redirect_to dashboard_learning_path_path, notice: "Aun no puedes acceder a este contenido." 
  end

  def redirect_to_learning_nil
    if Program.where(id: params[:program_id]).empty?
      redirect_to dashboard_learning_path_path, notice: "El contenido al que intentas acceder no existe o ha sido eliminado, por favor intenta con otro diferente." 
    else
      redirect_to dashboard_program_path(params[:program_id]), notice: "El contenido al que intentas acceder no existe o ha sido eliminado, por favor intenta con otro contenido de este programa." 
    end
  end

  def redirect_to_support
    redirect_to dashboard_support_admin_path, notice: "No tienes asignado un grupo, contacta al administrador para que te asigne a uno." 
  end    

  helper_method :mailbox, :conversation

  private
  def sessions_controller?
    action_name == "new" && controller_name == "sessions"
  end

  def invitations_controller?
    (action_name == 'edit' || action_name == 'update') && controller_name == 'invitations'
  end

  def registrations_controller?
    (action_name == 'new' || action_name == 'create') && controller_name == 'registrations'
  end

  def set_breadcrumb
    if (action_name == 'edit' || action_name == 'update') && controller_name == 'registrations'
      add_breadcrumb (ENV['COMPANY_NAME'].nil? ? "Inicio" : ENV['COMPANY_NAME']), :root_path
      add_breadcrumb "<a class='active' href='#{edit_user_registration_path}'>Edita tu perfil</a>".html_safe
    end
  end

  def mailbox
    @mailbox ||= current_user.mailbox
  end
  def conversation
    @conversation ||= mailbox.conversations.find(params[:id])
  end
end
