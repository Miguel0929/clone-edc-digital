class Group < ActiveRecord::Base
  acts_as_paranoid

  validates_presence_of :name, :key
  validates_uniqueness_of :key
end
