class UserTracker < ActiveRecord::Base
	belongs_to :group, class_name: 'Group', foreign_key: 'old_group'
end
