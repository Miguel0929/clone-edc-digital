class Chapter < ActiveRecord::Base
  validates_presence_of :name, :points
  validates_numericality_of :points

  has_many :chapter_contents, -> { order(position: :asc) }
  has_many :lessons, :through => :chapter_contents, :source => :coursable, :source_type => 'Lesson'
  has_many :questions, :through => :chapter_contents, :source => :coursable, :source_type => 'Question'
  belongs_to :program

  acts_as_list scope: :program
end
