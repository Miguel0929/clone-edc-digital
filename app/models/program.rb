class Program < ActiveRecord::Base
  validates_presence_of :name

  has_many :chapters
end
