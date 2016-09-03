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
  validates_numericality_of :points

  def comments_for(user)
    user_answer = answers.find_by(user: user)
    user_answer.nil? ? 0 : user_answer.comments.count
  end

  def chapter_content
    ChapterContent.find_by(coursable_id: self.id, coursable_type: 'Question')
  end
end
