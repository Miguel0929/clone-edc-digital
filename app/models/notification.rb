class Notification < ActiveRecord::Base
  belongs_to :user
  belongs_to :notificable, polymorphic: true

  def model
    notificable_type.constantize.find(notificable_id)
  end
end
