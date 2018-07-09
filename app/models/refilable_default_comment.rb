class RefilableDefaultComment < ActiveRecord::Base

  belongs_to :template_refilable
  validates_presence_of :name, :content

end
