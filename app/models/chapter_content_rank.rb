class ChapterContentRank < ActiveRecord::Base
  belongs_to :user
  belongs_to :chapter_content
end
