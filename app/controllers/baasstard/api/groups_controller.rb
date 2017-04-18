class Baasstard::Api::GroupsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :cors_set_access_control_headers

  def index
    render json: Group.all
  end

  private
  def cors_set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, GET, PUT, DELETE, OPTIONS'
    headers['Access-Control-Allow-Headers'] = 'Origin, Content-Type, Accept, Authorization, Token'
    headers['Access-Control-Max-Age'] = "1728000"
  end
end
