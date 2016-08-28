class Group < ActiveRecord::Base
  acts_as_paranoid

  has_many :group_programs
  has_many :programs, through: :group_programs

  validates_presence_of :name, :key
  validates_uniqueness_of :key
end
