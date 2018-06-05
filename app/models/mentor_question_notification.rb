class MentorQuestionNotification < ActiveRecord::Base
  belongs_to :chapter_content
  belongs_to :user

  enum notification_type: [:update_question]
end
