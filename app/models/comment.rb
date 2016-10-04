class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :answer

  validates_presence_of :content
  after_create :create_notification

  private
  def create_notification
    if user.mentor?
      ActiveRecord::Base.transaction do
        student = answer.user
        comment_notification = student.comment_notifications.build(comment: self, user: user)
        comment_notification.save
        student.comment_notifications << comment_notification
      end
    else
      ActiveRecord::Base.transaction do
        user.group.users.each do |mentor|
          comment_notification = mentor.comment_notifications.build(comment: self, user: user)
          comment_notification.save
          mentor.comment_notifications << comment_notification
        end
      end
    end
  end
end
