class Chapter < ActiveRecord::Base
  validates_presence_of :name, :points
  validates_numericality_of :points

  has_many :chapter_contents, -> { order(position: :asc) }, dependent: :destroy
  has_many :lessons, :through => :chapter_contents, :source => :coursable, :source_type => 'Lesson', dependent: :destroy
  has_many :questions, :through => :chapter_contents, :source => :coursable, :source_type => 'Question', dependent: :destroy
  has_many :evaluations
  belongs_to :program

  acts_as_list scope: :program

  accepts_nested_attributes_for :evaluations, reject_if: :all_blank, allow_destroy: true
end
