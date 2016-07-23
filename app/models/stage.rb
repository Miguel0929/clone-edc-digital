class Stage < ActiveRecord::Base
  validates_presence_of :name

  has_many :stage_contents, -> { order(position: :asc) }, class_name: 'StageContent', foreign_key: 'stage_id'
  has_many :lessons, :through => :stage_contents, :source => :coursable, :source_type => 'Lesson'
  has_many :questions, :through => :stage_contents, :source => :coursable, :source_type => 'Question'
  belongs_to :chapter
end
