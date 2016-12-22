class Mentors::GroupsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_mentor

  def index
    @groups = current_user.groups.includes(:programs, :users)
  end

  def show
    @group = current_user.groups.includes(:programs, :users, :active_students).find(params[:id])
  end
end
