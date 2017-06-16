class NewProgramNotificationProgJob < ActiveJob::Base
  include SuckerPunch::Job

  def perform(program, ruta)
    program.groups.each do |group|
      group.students.each do |student|
        student.program_notifications.create(program: program, notification_type: 'new_program')
        Programs.new_program(program, student, ruta)
      end
    end
  end

end  
