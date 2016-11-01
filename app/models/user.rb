class User < ActiveRecord::Base
  attr_accessor :agreement
  acts_as_paranoid
  mount_uploader :profile_picture, ProfilePictureUploader

  enum role: [ :student, :mentor, :admin ]
  enum gender: [ :male, :female ]

  has_many :answers
  has_many :group_users
  has_many :groups, through: :group_users
  has_many :trackers
  has_many :notifications
  has_many :comment_notifications, :through => :notifications, :source => :notificable, :source_type => 'CommentNotification'
  has_many :program_notifications, :through => :notifications, :source => :notificable, :source_type => 'ProgramNotification'

  devise :database_authenticatable, :recoverable, :invitable, :validatable, :registerable

  scope :students, -> { where(role: 0) }
  scope :mentors, -> { where(role: 1) }
  scope :invitation_accepted, -> { where.not('invitation_accepted_at' => nil) }

  validates_presence_of :first_name, :last_name, :phone_number
  validates_acceptance_of :agreement

  belongs_to :group

  before_create :set_origin
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
    answers.map{ |asnwer| asnwer.question.chapter_content.chapter.program}.uniq.compact
  end

  def has_answer_question?(model)
    !answers.where(question: model).empty?
  end

  def answer_for(question)
    answer = answers.find_by(question: question)
    answer.nil? ? nil : answer
  end

  def limited_notifications
    notifications.limit(3).order(created_at: :desc)
  end

  def has_notifications?
    notifications.where(read: false).count > 0
  end

  private

  def set_origin
    self.state = 'Ciudad de México'
    self.city = 'Distrito Federal'
  end

  def assign_group
    if mentor?
      group.users << self
    end
  end
end
