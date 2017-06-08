class ChapterStat < ActiveRecord::Base
  belongs_to :user
  belongs_to :chapter

  validates :user_id, presence: true
  validates :chapter_id, presence: true
end
