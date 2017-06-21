class NewProgramNotificationProgJob < ActiveJob::Base
  include SuckerPunch::Job

  def perform(program, ruta)
    program.groups.each do |group|
      group.students.each do |student|
        student.program_notifications.create(program: program, notification_type: 'new_program')
        if student.panel_notifications.new_program.first.nil? || student.panel_notifications.new_program.first.status
        	Programs.new_program(program, student, ruta)
        end	
      end
    end
  end

end  
