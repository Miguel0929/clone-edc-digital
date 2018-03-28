class MentorProgramNotification < ActiveRecord::Base
  belongs_to :program
  belongs_to :user

   enum notification_type: [:more95, :complete, :key_question]
end
