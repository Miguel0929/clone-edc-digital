class ChapterContent < ActiveRecord::Base
  belongs_to :chapter
  belongs_to :coursable, polymorphic: true

  has_many :trackers

  acts_as_list scope: :chapter

  def model
    coursable_type.constantize.find(coursable_id)
  end
end
