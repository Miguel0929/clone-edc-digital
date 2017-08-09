class ProgramCompleteNotificationJob < ActiveJob::Base
  include SuckerPunch::Job

  def perform(program, user, ruta)
  	user.group.users.each do |mentor|
      mentor.mentor_program_notifications.create(program: program, user: user, notification_type: 'complete')
      if mentor.panel_notifications.complete_mentor.first.nil? || mentor.panel_notifications.complete_mentor.first.status
      	Programs.complete_mentor(program, mentor, user, ruta)
      end  
    end
  end
end  	