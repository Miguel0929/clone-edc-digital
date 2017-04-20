class Quiz < ActiveRecord::Base
  has_many :quiz_questions
  validates_presence_of :name, :description
end
