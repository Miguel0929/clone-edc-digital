class Answer < ActiveRecord::Base
  belongs_to :user
  belongs_to :question
  has_many :comments

  validates_presence_of :answer_text
end
