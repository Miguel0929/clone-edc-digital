class Program < ActiveRecord::Base
  mount_uploader :cover, CoverUploader

  has_many :chapters
  has_many :group_programs
  has_many :groups, through: :group_programs

  validates_presence_of :name, :description, :cover
end
