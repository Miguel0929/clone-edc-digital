class LearningPathNotification < ActiveRecord::Base
  belongs_to :group
  has_many :notification, as: :notificable
end
