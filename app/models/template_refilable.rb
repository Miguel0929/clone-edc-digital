class TemplateRefilable < ActiveRecord::Base
  acts_as_list
  
  has_many :group_template_refilables
  has_many :groups, through: :group_template_refilables
  has_many :refilables

  validates_presence_of :name, :description, :content
end
