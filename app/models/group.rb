class Group < ActiveRecord::Base
  acts_as_paranoid

  has_many :group_programs
  has_many :group_users
  has_many :programs, through: :group_programs
  has_many :users, through: :group_users

  validates_presence_of :name, :key
  validates_uniqueness_of :key
end
