class Mobile::FrequentsController < Mobile::BaseController

  def index
    render json: Frequent.all
  end
end
