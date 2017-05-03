class Program < ActiveRecord::Base
  acts_as_list

  mount_uploader :cover, CoverUploader

  has_many :chapters, -> { order(position: :asc) }, dependent: :destroy
  has_many :group_programs
  has_many :groups, through: :group_programs
  has_many :program_notifications, dependent: :destroy
  has_many :ratings, as: :ratingable 

  validates_presence_of :name, :description, :cover

  def next_content_for(user)
    chapter_contents_visited = user.trackers.map(&:chapter_content)
    chapter_contents = chapters.map { |chapter| chapter.chapter_contents}.flatten
    next_content = chapter_contents.find { |chapter_content| !chapter_contents_visited.include?(chapter_content) }

    next_content.nil? ? [:dashboard, self] : [:dashboard, next_content]
  end

  def next_chapter(chapter)
    chapters.where("position > ?", chapter.position).first
  end

  def rating
    r=self.ratings.average(:rank)
    if r.nil?
      return 0.0
    else
      return r
    end 
    
  end 
end
