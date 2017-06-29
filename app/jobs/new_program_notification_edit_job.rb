class NewProgramNotificationEditJob < ActiveJob::Base
  include SuckerPunch::Job
  def perform(groups, program, ruta)
  	groups.each do |group|
  		group.active_students.each do |student|
      	student.program_notifications.create(program: program, notification_type: 'new_program')
      	if student.panel_notifications.new_program.first.nil? || student.panel_notifications.new_program.first.status
      		Programs.new_program(program, student, ruta)
      	end	
    	end
  	end
  end	
end  	