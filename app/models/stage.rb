class Stage < ActiveRecord::Base
  validates_presence_of :name

  belongs_to :chapter
end
