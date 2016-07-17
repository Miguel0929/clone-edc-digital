class Chapter < ActiveRecord::Base
  validates_presence_of :name

  has_many :stages
  belongs_to :program
end
