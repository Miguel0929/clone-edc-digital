class Api::V1::BaseController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :cors_set_access_control_headers

  def cors_set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, GET, PUT, DELETE, OPTIONS'
    headers['Access-Control-Allow-Headers'] = 'Origin, Content-Type, Accept, Authorization, Token'
    headers['Access-Control-Max-Age'] = "1728000"
  end

  protected
  def authorize
    if current_user.nil?
      render json: { error: 'invalid credentials' }, status: 401
    end
  end
end
