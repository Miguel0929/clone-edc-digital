class Rating < ActiveRecord::Base
  belongs_to :user
  belongs_to :ratingable, polymorphic: true

end
