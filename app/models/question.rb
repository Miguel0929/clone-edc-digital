class Question < ActiveRecord::Base
  TYPES = [
    ['Respuesta abierta - corta', 'short'], ['Respuesta abierta - párrafo', 'long'],
    ['Checkbox', 'checkbox'], ['Radio button', 'radio'], ['Select', 'dropdown']
  ]

  mount_uploader :support_image, SupportImageUploader

  has_many :answers, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :rubrics, dependent: :destroy

  enum question_type: [:short, :long, :checkbox, :radio, :dropdown]

  accepts_nested_attributes_for :rubrics

  validates_presence_of :question_text, :points
  validates_presence_of :answer_options, if: :options_question?
  validates_numericality_of :points


  def comments_for(user)
    comments.where(owner: user).count
  end

  def chapter_content
    ChapterContent.find_by(coursable_id: self.id, coursable_type: 'Question')
  end

  def options_question?
    checkbox? || dropdown? || radio?
  end
end
