class SessionsController < Devise::SessionsController
  before_action :track_ahoy_sign_out, only: [:destroy]

  private
  def track_ahoy_sign_out
  	puts "ay wey, sessions track_ahoy_sign_out"
    if cookies['ahoy_visit']
      visit = Visit.find_by(visit_token: cookies['ahoy_visit'], visitor_token: cookies['ahoy_visitor'])
      visit.update(finished_at: Time.now) unless visit.nil?
    end
  end
end
