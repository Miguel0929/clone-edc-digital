class Rubric < ActiveRecord::Base
  belongs_to :question

  validates_presence_of :criteria, :base
end
