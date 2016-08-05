class Chapter < ActiveRecord::Base
  validates_presence_of :name

  has_many :chapter_contents
  has_many :lessons, :through => :chapter_contents, :source => :coursable, :source_type => 'Lesson'
  has_many :questions, :through => :chapter_contents, :source => :coursable, :source_type => 'Question'
  belongs_to :program
end
