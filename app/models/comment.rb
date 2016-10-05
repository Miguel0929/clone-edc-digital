class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :answer

  validates_presence_of :content
  after_create :create_notification

  private
  def create_notification
    if user.mentor?
      answer.user.comment_notifications.create(comment: self, user: user)
    else
      ActiveRecord::Base.transaction do
        user.group.users.each do |mentor|
          mentor.comment_notifications.create(comment: self, user: user)
        end
      end
    end
  end
end
