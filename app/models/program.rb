class Program < ActiveRecord::Base
  has_many :chapters
  has_many :group_programs
  has_many :groups, through: :group_programs

  validates_presence_of :name
end
