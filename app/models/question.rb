class Question < ActiveRecord::Base
  TYPES = [
    ['Respuesta abierta - corta', 'short'], ['Respuesta abierta - párrafo', 'long'],
    ['Checkbox', 'checkbox'], ['Radio button', 'radio'], ['Select', 'dropdown']
  ]

  has_many :answers
  has_many :rubrics

  enum question_type: [:short, :long, :checkbox, :radio, :dropdown]

  accepts_nested_attributes_for :rubrics

  validates_presence_of :question_text, :points
end
