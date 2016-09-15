class Lesson < ActiveRecord::Base
  validates_presence_of :identifier

  has_many :stage_contents
end
