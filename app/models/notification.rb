class Notification < ActiveRecord::Base
  belongs_to :user
  belongs_to :notificable, polymorphic: true
end
