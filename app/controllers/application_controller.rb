class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  skip_before_filter :verify_authenticity_token, if: -> { controller_name == 'sessions' && action_name == 'create' }
  before_filter :configure_permitted_parameters, if: :devise_controller?
  before_filter :set_breadcrumb, if: :devise_controller?
  before_filter :banned?
  layout :layout_by_resource
  helper_method :xeditable?

  def xeditable? object = nil
    true
  end

  protected
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :phone_number, :email, :industry_id,:password, :password_confirmation, :agreement])
    devise_parameter_sanitizer.for(:accept_invitation).concat [:first_name, :last_name, :phone_number, :agreement]
    devise_parameter_sanitizer.for(:invite).concat [:role, :group_id]
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :phone_number, :email, :password, :password_confirmation, :gender, :bio, :state, :city, :profile_picture, :industry_id])
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
      add_breadcrumb "EDC DIGITAL", :root_path
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
