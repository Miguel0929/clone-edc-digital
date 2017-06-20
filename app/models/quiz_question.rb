class QuizQuestion < ActiveRecord::Base
  TYPES = [
    ['Checkbox', 'checkbox'], ['Radio button', 'radio'], ['Select', 'dropdown']
  ]
  belongs_to :quiz
  has_many :quiz_answers, dependent: :nullify

  enum question_type: [:checkbox, :radio, :dropdown]
end
