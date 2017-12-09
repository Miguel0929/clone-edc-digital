class MentorProgramNotification < ActiveRecord::Base
  belongs_to :program
  belongs_to :user

   enum notification_type: [:more80, :complete]
end
