class Answer < ActiveRecord::Base
  belongs_to :user
  belongs_to :question
  belongs_to :rubric
  has_many :comments

  validates_presence_of :answer_text

  def humanize_answer
    return answer_text unless question.question_type == 'checkbox'
    answer_text.split('\n').join(' - ')
  end
end
