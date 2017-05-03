class ChapterContent < ActiveRecord::Base
  belongs_to :chapter
  belongs_to :coursable, polymorphic: true

  has_many :trackers
  has_many :ratings, as: :ratingable 

  acts_as_list scope: :chapter

  def model
    coursable_type.constantize.find(coursable_id)
  end
  def rating
  	r=self.chapter_content_ranks.average(:rank)
  	if r.nil?
  		return 0.0
  	else
  		return r
  	end	
  	
  end	
end
