class NewContentNotificationJob < ActiveJob::Base
  include SuckerPunch::Job

  def perform(program, ruta)
    program.groups.each do |group|
      group.students.each do |student|
        student.program_notifications.create(program: program, notification_type: 'new_content')

        if student.panel_notifications.up_program.first.nil? || student.panel_notifications.up_program.first.status
          #Programs.up_program(program, student, ruta)
        end 

      end
    end
  end
end
