class TrackSessionsController < ApplicationController
  before_action :authenticate_user!

  def create
    sessions = current_user.sessions.where('finish >= ?', 10.minutes.ago)

    if sessions.empty?
      user_agent = UserAgent.parse(request.user_agent)

      current_user.sessions.create({
        browser: user_agent.browser,
        platform: user_agent.platform,
        device_type: request.user_agent =~ /Mobile|webOS/ ? 'Mobile' : 'Desktop',
        start: Time.current,
        finish: Time.current,
      })
    else
      sessions.last.update(finish: Time.current)
    end

    render json: { status: :ok }
  end
end
