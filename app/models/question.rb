class Question < ActiveRecord::Base
  enum question_type: [:short, :long, :checkbox, :radio, :dropdown]

  validates_presence_of :question_text
end
