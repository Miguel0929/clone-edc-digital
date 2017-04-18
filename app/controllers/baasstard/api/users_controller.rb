class Baasstard::Api::UsersController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :cors_set_access_control_headers

  def show
    user = User.find_by(email: params[:email])

    if user.nil?
      render json: {}, status: :not_found
    else
      render json: {
        created_at: user.created_at.strftime('%d/%m/%Y  %H:%M:%S'),
        status: user.status,
        invitation_accepted_at: user.invitation_accepted_at.nil? ? '' : user.invitation_accepted_at.strftime('%m/%d/%Y  %H:%M:%S'),
        history: format_user_sessions(user.sessions),
        content_visited_percentage: user.content_visited_percentage,
        answered_questions_percentage: user.answered_questions_percentage,
        programs: format_programs(user)
      },
      status: :ok
    end
  end

  def invite
    user = User.invite!(email: params[:email], group_id: params[:group_id])
    render json: user, status: :ok
  end

  private
  def format_programs(user)
    user.group.programs.map do |program|
      {
        program: program,
        percentage_content_visited: user.percentage_content_visited_for(program),
        percentage_questions_answered: user.percentage_questions_answered_for(program)
      }
    end
  end

  def format_user_sessions(sessions)
    sessions.map do |session|
      {
        browser: session.browser,
        device_type: session.device_type,
        platform: session.platform,
        start: session.start.nil? ? '' : session.start.strftime('%d/%m/%Y  %H:%M:%S'),
        finish: session.finish.nil? ? '' : session.finish.strftime('%d/%m/%Y  %H:%M:%S'),
      }
    end
  end

  def cors_set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, GET, PUT, DELETE, OPTIONS'
    headers['Access-Control-Allow-Headers'] = 'Origin, Content-Type, Accept, Authorization, Token'
    headers['Access-Control-Max-Age'] = "1728000"
  end
end
