class QuizQuestion < ActiveRecord::Base
  TYPES = [
    ['Checkbox', 'checkbox'], ['Radio button', 'radio'], ['Select', 'dropdown']
  ]
  belongs_to :quiz

  enum question_type: [:checkbox, :radio, :dropdown]
end
