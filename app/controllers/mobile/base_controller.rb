class Mobile::BaseController < ActionController::Base
  acts_as_token_authentication_handler_for User, fallback: :none
  before_action :cors_set_access_control_headers

  protected
  def cors_set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, GET, PUT, DELETE, OPTIONS'
    headers['Access-Control-Allow-Headers'] = 'Origin, Content-Type, Accept, Authorization, Token'
    headers['Access-Control-Max-Age'] = "1728000"
  end

  def sessions_controller?
    controller_name == "sessions"
  end

  def authorize
    unless  current_user
      render json: { error: 'invalid credentials' }, status: 401
    end
  end

  def authorize_by_url
    user = User.find_by(email: params[:user_email], authentication_token: params[:user_token])
    if user
      sign_in(user)
    else
      render json: { error: 'invalid credentials' }, status: 401
    end
  end
end
