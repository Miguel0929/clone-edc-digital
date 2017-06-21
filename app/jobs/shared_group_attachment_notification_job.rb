class SharedGroupAttachmentNotificationJob < ActiveJob::Base
  include SuckerPunch::Job

  def perform(attachment, ruta)
    attachment.groups.each do |group|
      group.active_students.each do |student|
        student.shared_group_attachment_notifications.create(shared_group_attachment_id: attachment.id)
        if student.panel_notifications.shared_file.first.nil? || student.panel_notifications.shared_file.first.status
        	SharedGroupAttachmentMailer.shared_file(student, ruta)
        end	
      end
    end  
  end

end 