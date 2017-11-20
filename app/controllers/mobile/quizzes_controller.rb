class Mobile::QuizzesController < Mobile::BaseController
  before_action :authorize

  def index
    quizzes = current_user.group.quizzes.select(
      "quizzes.*, (select count(*) from attempts) as attempts"
    )

    render json: quizzes
  end
end
