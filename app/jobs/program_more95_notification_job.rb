class ProgramMore95NotificationJob < ActiveJob::Base
  include SuckerPunch::Job

  def perform(program, user, ruta)
  	user.group.users.each do |mentor|
      mentor.mentor_program_notifications.create(program: program, user: user, notification_type: 'more95')
      if mentor.panel_notifications.more95_mentor.first.nil? || mentor.panel_notifications.more95_mentor.first.status
       	Programs.more95_mentor(program, mentor, user, ruta)
      end  
    end
  end
end  	