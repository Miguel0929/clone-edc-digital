class LearningPathNotificationJob < ActiveJob::Base
  include SuckerPunch::Job

  def perform(group, ruta)
  	group.active_students.each do |student|
      student.learning_path_notifications.create(group: @group)
      if student.panel_notifications.up_ruta.first.nil? || student.panel_notifications.up_ruta.first.status
        LearningPathMailer.up_learning_path(student, ruta)
      end  
    end

  end
end  	