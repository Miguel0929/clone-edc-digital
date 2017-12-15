class ProgramNotification < ActiveRecord::Base
  belongs_to :program

  enum notification_type: [:rubric, :new_content, :new_program, :evaluation, :more95, :complete]
end
