class Baasstard::Api::UsersController < ApplicationController
  skip_before_action :verify_authenticity_token

  def show
    user = User.find_by(email: params[:email])

    if user.nil?
      render json: {}, status: :not_found
    else
      render json: {
        created_at: user.created_at,
        status: user.status,
        invitation_accepted_at: user.invitation_accepted_at,
        history: user.sessions,
        content_visited_percentage: user.content_visited_percentage,
        answered_questions_percentage: user.answered_questions_percentage,
        programs: format_programs(user)
      },
      status: :ok
    end
  end

  private
  def format_programs(user)
    user.programs.map do |program|
      {
        program: program,
        percentage_content_visited: user.percentage_content_visited_for(program),
        percentage_questions_answered: user.percentage_questions_answered_for(program)
      }
    end
  end
end
