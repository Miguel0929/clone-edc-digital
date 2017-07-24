class GroupTemplateRefilable < ActiveRecord::Base
  belongs_to :group
  belongs_to :template_refilable
end
