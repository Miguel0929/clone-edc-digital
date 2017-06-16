class NewContentNotificationJob < ActiveJob::Base
  include SuckerPunch::Job

  def perform(program, ruta)
  	p "================================================="
    program.groups.each do |group|
      group.students.each do |student|
        student.program_notifications.create(program: program, notification_type: 'new_content')
        Programs.up_program(program, student, ruta)
      end
    end
  end
end
