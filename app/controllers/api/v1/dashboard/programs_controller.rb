class Api::V1::Dashboard::ProgramsController < Api::V1::BaseController
  before_action :authorize

  def index
    render json: current_user.group.programs
  end
end
