class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_filter :configure_permitted_parameters, if: :devise_controller?
  before_filter :set_breadcrumb, if: :devise_controller?
  layout :layout_by_resource

  protected
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :phone_number, :email, :password, :password_confirmation, :agreement])
    devise_parameter_sanitizer.for(:accept_invitation).concat [:first_name, :last_name, :phone_number, :agreement]
    devise_parameter_sanitizer.for(:invite).concat [:role, :group_id]
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :phone_number, :email, :password, :password_confirmation, :gender, :bio, :state, :city, :profile_picture])
  end

  def after_sign_in_path_for(resource)
    flash.clear
    if resource.admin?
      users_path
    elsif resource.mentor?
      students_users_path
    elsif resource.student?
      welcome_path
    end
  end

  def require_admin
    redirect_to root_url unless current_user.admin?
  end

  def require_mentor
    redirect_to root_url if current_user.student?
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
      add_breadcrumb "EDCDIGITAL", :root_path
      add_breadcrumb "<a class='active' href='#{edit_user_registration_path}'>Edita tu perfil</a>".html_safe
    end
  end
end
