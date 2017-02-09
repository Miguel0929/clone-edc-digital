class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :answer
  belongs_to :owner, class_name: 'User', foreign_key: 'owner_id'
  belongs_to :question

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
