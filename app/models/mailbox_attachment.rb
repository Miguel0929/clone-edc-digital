class MailboxAttachment < ActiveRecord::Base
	validates_presence_of :file
	mount_uploader :file, MailboxAttachmentUploader
end
