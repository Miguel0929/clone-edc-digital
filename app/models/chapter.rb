class Chapter < ActiveRecord::Base
  validates_presence_of :name

  belongs_to :program
end
