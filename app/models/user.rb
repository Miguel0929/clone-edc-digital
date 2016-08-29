class User < ActiveRecord::Base
  acts_as_paranoid

  enum role: [ :student, :mentor, :admin ]

  has_many :answers

  devise :database_authenticatable, :recoverable, :invitable, :validatable

  scope :students, -> { where(role: 0) }
  scope :mentors, -> { where(role: 1) }
  scope :invitation_accepted, -> { where.not('invitation_accepted_at' => nil) }

  validates_presence_of :first_name, :last_name, :phone_number

  belongs_to :group

  after_create :assign_group

  def name
    "#{first_name} #{last_name}"
  end

  def huminize_role
    roles = {student: 'Estudiante', mentor: 'Mentor', admin: 'Administrador'}
    roles[role.to_sym]
  end

  def status
    invitation_accepted_at.nil? ? 'Inactivo' : 'Activo'
  end

  def answers_for(chapter)
    questions = chapter.questions
    answers.select { |answer| questions.include?(answer.question) }
  end

  private
  def assign_group
    if mentor?
      group.users << self
    end
  end
end
