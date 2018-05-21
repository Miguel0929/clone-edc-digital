class Lesson < ActiveRecord::Base
  validates_presence_of :identifier

  has_many :stage_contents

  def chapter_content
    ChapterContent.find_by(coursable_id: self.id, coursable_type: 'Lesson')
  end
end
