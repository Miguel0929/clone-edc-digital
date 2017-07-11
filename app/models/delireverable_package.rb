class DelireverablePackage < ActiveRecord::Base
  has_many :group_delireverable_packages
  has_many :groups, through: :group_delireverable_packages

  validates_presence_of :name, :description
end
