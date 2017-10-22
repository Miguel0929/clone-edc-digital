class Mobile::FrequentsController < Mobile::BaseController
  before_action :authorize

  def index
    render json: Frequent.all
  end
end
