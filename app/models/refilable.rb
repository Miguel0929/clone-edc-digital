class Refilable < ActiveRecord::Base
  belongs_to :user
  belongs_to :template_refilable
end
