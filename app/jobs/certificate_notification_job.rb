class CertificateNotificationJob < ActiveJob::Base
  include SuckerPunch::Job

  def perform(recipient_address, program, route, certificate_link)
  	#user.group.users.each do |mentor|
    #  mentor.mentor_program_notifications.create(program: program, user: user, notification_type: 'key_question')
    #  if mentor.panel_notifications.complete_mentor.first.nil? || mentor.panel_notifications.complete_mentor.first.status
      	CertificateMailer.certificate_sender(recipient_address, program, route, certificate_link)
    #  end  
    #end
  end
end  	