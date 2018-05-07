class AnsweredRefilableNotificationJob < ActiveJob::Base
  include SuckerPunch::Job

  def perform(program, template_refilable, user, student, ruta)
  	#user.group.users.each do |mentor|
    #  mentor.mentor_program_notifications.create(program: program, user: user, notification_type: 'key_question')
    #  if mentor.panel_notifications.complete_mentor.first.nil? || mentor.panel_notifications.complete_mentor.first.status
      	Programs.answered_refilable(program, template_refilable, user, student, ruta)
    #  end  
    #end
  end
end  	