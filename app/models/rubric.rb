class Rubric < ActiveRecord::Base
  belongs_to :question

  validates_presence_of :criteria, :base

  def criteria_extended
    "#{criteria} - #{base}"
  end
end
