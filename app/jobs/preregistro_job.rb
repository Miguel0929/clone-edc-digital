class PreregistroJob < ActiveJob::Base
  include SuckerPunch::Job

  def perform(email, type)
    if type == "reenviar"
      User.invite!(:email => email)
    elsif type == "nuevo"
      group = Group.find_by(key: "rcpn")
      User.invite!(:email => email, group: group, role: 0)
    end     
  end
end   