class Baasstard::Api::GroupsController < ApplicationController
  def index
    render json: Group.all
  end
end
