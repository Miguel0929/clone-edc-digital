class TemplateRefilable < ActiveRecord::Base
  has_many :group_template_refilables
  has_many :groups, through: :group_template_refilables

  validates_presence_of :name, :description, :content
end
