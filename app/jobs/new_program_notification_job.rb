class NewProgramNotificationJob < ActiveJob::Base
  queue_as :default

  def perform(before_update_ids, after_update_ids)
    programs_before_update = Program.find(before_update_ids)
    programs_after_update = Program.find(after_update_ids)

    programs_after_update.each do |program|
      create_notification(program) unless programs_before_update.include?(program)
    end
  end

  private
  def create_notification(program)
    program.groups.each do |group|
      group.students.each do |student|
        student.program_notifications.create(program: program, notification_type: 'new_program')
      end
    end
  end
end