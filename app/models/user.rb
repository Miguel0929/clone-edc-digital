class User < ActiveRecord::Base
  attr_accessor :agreement
  acts_as_paranoid

  enum role: [ :student, :mentor, :admin ]

  has_many :answers
  has_many :group_users
  has_many :groups, through: :group_users
  has_many :trackers

  devise :database_authenticatable, :recoverable, :invitable, :validatable, :registerable

  scope :students, -> { where(role: 0) }
  scope :mentors, -> { where(role: 1) }
  scope :invitation_accepted, -> { where.not('invitation_accepted_at' => nil) }

  validates_presence_of :first_name, :last_name, :phone_number
  validates_acceptance_of :agreement

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

  def programs
    answers.map{ |asnwer| asnwer.question.chapter_content.chapter.program}.uniq
  end

  def has_answer_question?(model)
    !answers.where(question: model).empty?
  end

  private
  def assign_group
    if mentor?
      group.users << self
    end
  end
end
