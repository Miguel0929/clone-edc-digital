class Group < ActiveRecord::Base
  acts_as_paranoid

  has_many :group_programs
  has_many :group_users
  has_many :programs, through: :group_programs
  has_many :users, through: :group_users, validate: false
  has_many :students, -> { students }, class_name: 'User', foreign_key: 'group_id'
  has_many :active_students, -> { where('invitation_accepted_at IS NOT NULL and role = 0')}, class_name: 'User', foreign_key: 'group_id'

  validates_presence_of :name, :key
  validates_uniqueness_of :key
end
