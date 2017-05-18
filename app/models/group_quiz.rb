class GroupQuiz < ActiveRecord::Base
  belongs_to :group
  belongs_to :quiz
end
