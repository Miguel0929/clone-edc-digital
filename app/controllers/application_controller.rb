class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_filter :configure_permitted_parameters, if: :devise_controller?

  protected
  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:accept_invitation).concat [:first_name, :last_name, :phone_number]
    devise_parameter_sanitizer.for(:invite).concat [:role]
  end

  def after_sign_in_path_for(resource)
    if resource.admin? || resource.mentor?
      users_path
    elsif resource.student?
      dashboard_programs_path
    end
  end

  def require_admin
    redirect_to root_url unless current_user.admin?
  end

  def require_mentor
    redirect_to root_url if current_user.student?
  end
end
