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
  has_many :visits
  has_many :events, class_name: 'Ahoy::Event'

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

  def content_visted_for(program)
    trackers.joins(chapter_content: [chapter: [:program]]).where("chapter_contents.coursable_type = 'Lesson' AND programs.id = ?", program.id).count
  end

  def questions_answered_for(program)
    program.chapters.joins(questions: [:answers]).where('answers.user_id': self.id).count
  end

  def total_comments_for(program)
    program.chapters.joins(questions: [answers: [:comments]]).where('comments.user_id': self.id).count
  end

  def percentage_content_visited_for(program)
    total = program.chapters.joins(:lessons).select('lessons.*').count
    (content_visted_for(program) * 100) / total
  end

  def percentage_questions_answered_for(program)
    total = program.chapters.joins(:questions).select('questions.*').count
    (questions_answered_for(program) * 100) / total
  end

  def answered_questions_percentage
    total_of_answers = group.programs.joins(chapters: [questions: [:answers]]).where('answers.user_id': self.id).count
    total_of_questions = group.programs.joins(chapters: [:questions]).select('questions.*').count

    (total_of_answers * 100) / total_of_questions
  end

  def content_visited_percentage
    total_of_visited_contents = trackers.joins(chapter_content: [chapter: [:program]]).where("chapter_contents.coursable_type = 'Lesson' AND programs.id in (?)", group.programs.pluck(:id)).count
    total_of_contents = group.programs.joins(chapters: [:chapter_contents]).where("chapter_contents.coursable_type = 'Lesson'").count

    (total_of_visited_contents * 100) / total_of_contents
  end

  def total_views_of_content(chapter_content)
    events.where(name: 'Viewed content').where_properties(chapter_content_id: chapter_content.id).count
  end

  def total_of_editions(chapter_content)
    answer = answer_for(chapter_content.model)

    answer.nil? ? 0 : events.where(name: 'Answer updated').where_properties(answer_id: answer.id).count
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
