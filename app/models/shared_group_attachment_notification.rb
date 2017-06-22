class SharedGroupAttachmentNotification < ActiveRecord::Base
  belongs_to :shared_group_attachment
  has_many :notification, as: :notificable
end
