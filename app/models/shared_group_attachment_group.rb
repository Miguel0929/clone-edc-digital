class SharedGroupAttachmentGroup < ActiveRecord::Base
  belongs_to :group
  belongs_to :shared_group_attachment
end
