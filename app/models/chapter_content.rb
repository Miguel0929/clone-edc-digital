class ChapterContent < ActiveRecord::Base
  belongs_to :chapter
  belongs_to :coursable, polymorphic: true, :dependent => :destroy

  has_many :trackers
  has_many :ratings, as: :ratingable 
  has_many :reports, as: :reportable

  acts_as_list scope: :chapter

  def model
    coursable_type.constantize.find(coursable_id)
  end
  def rating
  	r=self.ratings.average(:rank)
  	if r.nil?
  		return 0.0
  	else
  		return r
  	end	
  end
  def rating_count
    return self.ratings.count
  end

  def next_content
    self.chapter.chapter_contents.where("position > ?", self.position).order(:position).first
  end

  def previous_content
    self.chapter.chapter_contents.where("position < ?", self.position).order(:position).last
  end	
end
