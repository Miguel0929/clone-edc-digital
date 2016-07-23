class Question < ActiveRecord::Base
  TYPES = [
    ['Respuesta abierta - corta', 'short'], ['Respuesta abierta - párrafo', 'long'],
    ['Checkbox', 'checkbox'], ['Radio button', 'radio'], ['Select', 'dropdown']
  ]

  enum question_type: [:short, :long, :checkbox, :radio, :dropdown]

  validates_presence_of :question_text
end
