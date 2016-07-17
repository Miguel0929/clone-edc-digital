class Lesson < ActiveRecord::Base
  validates_presence_of :content, :identifier

  has_many :stage_contents
end
