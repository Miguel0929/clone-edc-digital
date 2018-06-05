class UpdateQuestionNotificationJob < ActiveJob::Base
  include SuckerPunch::Job

  def perform(chapter_content, user, ruta)
  	user.group.users.each do |mentor|
      mentor.mentor_question_notifications.create(chapter_content: chapter_content, user: user, notification_type: 'update_question')
      if mentor.panel_notifications.update_question.first.nil? || mentor.panel_notifications.update_question.first.status
      	Programs.update_question(chapter_content, mentor, user, ruta)
      end  
    end
  end
end  	