class Program < ActiveRecord::Base
  mount_uploader :cover, CoverUploader

  has_many :chapters, -> { order(position: :asc) }, dependent: :destroy
  has_many :group_programs
  has_many :groups, through: :group_programs

  validates_presence_of :name, :description, :cover

  def next_content_for(user)
    chapter_contents_visited = user.trackers.map(&:chapter_content)
    chapter_contents = chapters.map { |chapter| chapter.chapter_contents}.flatten
    next_content = chapter_contents.find { |chapter_content| !chapter_contents_visited.include?(chapter_content) }

    next_content.nil? ? [:dashboard, self] : [:dashboard, next_content]
  end

  def next_chapter(chapter)
    chapters.where("id > ?", chapter.id).first
  end
end
