class RefilableNotification < ActiveRecord::Base
	belongs_to :template_refilable

  enum notification_type: [:rubric, :comment]
end
