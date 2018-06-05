class KeyQuestionNotificationJob < ActiveJob::Base
  include SuckerPunch::Job

  def perform(program, user, ruta)
  	user.group.users.each do |mentor|
      mentor.mentor_program_notifications.create(program: program, user: user, notification_type: 'key_question')
      if mentor.panel_notifications.key_question.first.nil? || mentor.panel_notifications.key_question.first.status
      	Programs.key_question(program, mentor, user, ruta)
      end  
    end
  end
end  	