class NewContentNotificationJob < ActiveJob::Base
  queue_as :default

  def perform(program)
    program.groups.each do |group|
      group.students.each do |student|
        student.program_notifications.create(program: program, notification_type: 'new_content')
      end
    end
  end
end
