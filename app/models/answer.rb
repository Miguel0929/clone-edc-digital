class Answer < ActiveRecord::Base
  belongs_to :user
  belongs_to :question
  belongs_to :rubric
  has_many :comments

  validates_presence_of :answer_text
  validates_uniqueness_of :user_id, scope: :question_id

  def humanize_answer
    return answer_text unless question.question_type == 'checkbox'
    answer_text.split('\n').join(' - ')
  end

  def result
    return 0 if rubric.nil?
    case rubric.criteria
    when 'Deficiente'
      question.points / 4
    when 'Regular'
      question.points / 3
    when 'Bueno'
      question.points / 2
    when 'Excelente'
      question.points / 1
    end
  end
end
