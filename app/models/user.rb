class User < ActiveRecord::Base
  attr_accessor :agreement
  acts_as_paranoid
  mount_uploader :profile_picture, ProfilePictureUploader
  ROLETYPES = [ ['Estudiante', 'student'], ['Mentor', 'mentor'], ['Administrador', 'admin'], ['Staff', 'staff']]

  enum role: [ :student, :mentor, :admin, :staff ]
  enum gender: [ :male, :female ]
  enum evaluation_status: [:'sin evaluar', :evaluad]

  has_many :answers
  has_many :group_users
  has_many :groups, through: :group_users
  has_many :trackers
  has_many :notifications
  has_many :comment_notifications, :through => :notifications, :source => :notificable, :source_type => 'CommentNotification'
  has_many :program_notifications, :through => :notifications, :source => :notificable, :source_type => 'ProgramNotification'
  has_many :visits
  has_many :events, class_name: 'Ahoy::Event'
  has_many :comments
  has_many :user_evaluations
  has_many :evaluations, through: :user_evaluations
  has_many :access_grants, dependent: :delete_all
  has_many :sessions
  has_many :attachments
  has_many :shared_attachments
  has_many :chapter_content_rank
  has_many :quiz_answers
  has_many :program_stats
  belongs_to :industry

  devise :database_authenticatable, :recoverable, :invitable, :validatable, :registerable, :omniauthable

  scope :students, -> { where(role: 0) }
  scope :mentors, -> { where(role: 1) }
  scope :staffs, -> { where(role: 3) }
  scope :invitation_accepted, -> { where.not('invitation_accepted_at' => nil) }
  scope :search, -> (query) {
    where('lower(users.first_name) LIKE lower(?) OR lower(users.last_name) LIKE lower(?) OR lower(users.email) LIKE lower(?)',
         "%#{query}%", "%#{query}%", "%#{query}%")
  }

  validates_presence_of :first_name, :last_name, :phone_number
  validates_acceptance_of :agreement

  belongs_to :group

  before_create :set_origin
  after_create :assign_group

  def self.authenticate(email, password)
    user = find_for_authentication(email: email)

    unless user.nil?
      user.valid_password?(password) ? user : nil
    end
  end

  def generate_authentication_token
    if authentication_token.blank?
      self.authentication_token = loop do
        token = Devise.friendly_token
        break token if token_suitable?(token)
      end

      self.save
    end
  end

  def token_suitable?(token)
    self.class.where(authentication_token: token).count == 0
  end

  def self.students_table

    chapters_ids = "select chapters.id from chapters "\
    "inner join programs on programs.id = chapters.program_id "\
    "inner join group_programs on programs.id = group_programs.program_id "\
    "where group_programs.group_id = users.group_id "

    answers_count = "(select count(answers.*) from answers "\
    "inner join questions on answers.question_id = questions.id "\
    "inner join chapter_contents on chapter_contents.coursable_id = questions.id "\
    "where chapter_contents.coursable_type = 'Question' "\
    "and chapter_contents.chapter_id in (#{chapters_ids}) "\
    "and answers.user_id = users.id) "

    lessons_count = "(select count(lessons.*) from lessons "\
    "inner join chapter_contents on chapter_contents.coursable_id = lessons.id "\
    "where chapter_contents.coursable_type = 'Lesson' "\
    "and chapter_contents.chapter_id in (#{chapters_ids})) "

    content_tracked_count = "(select count(*) from trackers "\
    "inner join chapter_contents on chapter_contents.id = trackers.chapter_content_id "\
    "where chapter_contents.chapter_id in (#{chapters_ids}) "\
    "and trackers.user_id = users.id "\
    "and chapter_contents.coursable_type = 'Lesson') "\

    select(
    "users.*, groups.name as group_name, (select count(*) from comments where comments.user_id = users.id) as comments_count, "\
    "(select count(questions) from questions "\
    "inner join chapter_contents on chapter_contents.coursable_id = questions.id "\
    "where chapter_contents.coursable_type = 'Question' and chapter_contents.chapter_id in (#{chapters_ids})) as questions_count, "\
    "#{answers_count} as answers_count," \
    "#{lessons_count} as content_count,"\
    "#{content_tracked_count} as content_tracked_count"
    )
    .joins('left outer join groups on groups.id = users.group_id')
    .where('users.role = 0')


  end


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
    group.programs
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

  def notifications_count
    return notifications.where(read: false).count
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

  def comments_count
    comments.count
  end

  def percentage_content_visited_for(program)
    total = program.chapters.joins(:lessons).select('lessons.*').count
    (content_visted_for(program) * 100) / total rescue 0
  end

  def percentage_questions_answered_for(program)
    total = program.chapters.joins(:questions).select('questions.*').count
    (questions_answered_for(program) * 100) / total rescue 0
  end

  def answered_questions_percentage
    return 0 if group.nil?
    
    total_of_answers = group.programs.joins(chapters: [questions: [:answers]]).where('answers.user_id': self.id).count
    total_of_questions = group.programs.joins(chapters: [:questions]).select('questions.*').count

    (total_of_answers * 100) / total_of_questions rescue 0
  end

  def content_visited_percentage
    return 0 if group.nil?

    total_of_visited_contents = trackers.joins(chapter_content: [chapter: [:program]]).where("chapter_contents.coursable_type = 'Lesson' AND programs.id in (?)", group.programs.pluck(:id)).count
    total_of_contents = group.programs.joins(chapters: [:chapter_contents]).where("chapter_contents.coursable_type = 'Lesson'").count

    (total_of_visited_contents * 100) / total_of_contents rescue 0
  end

  def total_views_of_content(chapter_content)
    events.where(name: 'Viewed content').where_properties(chapter_content_id: chapter_content.id).count
  end

  def total_of_editions(chapter_content)
    answer = answer_for(chapter_content.model)

    answer.nil? ? 0 : events.where(name: 'Answer updated').where_properties(answer_id: answer.id).count
  end

  acts_as_messageable


  def mailboxer_name
    self.name
  end

  def mailboxer_email(object)
    self.email
  end

  def limited_messages
    mailbox.inbox.limit(3).order(created_at: :desc)
  end

  def time_average
    return 0 if sessions.last.nil?
    t = 0
    sessions.each do |time|
      t += time.minutes
    end
    t / sessions.count
  end

  def total_time
    return 0 if sessions.last.nil?
    t = 0
    sessions.each do |time|
      t += time.minutes
    end
    t
  end

  def last_time
    return 'El usuario no ha iniciado sesión' if sessions.last.nil?
    TimeDifference.between(sessions.last.finish, Time.now)
        .humanize
        .gsub('Years', 'Año')
        .gsub('Months', 'Meses')
        .gsub('Weeks', 'Semanas')
        .gsub('Week', 'Semana')
        .gsub('Days', 'Dias')
        .gsub('Hours', 'Horas')
        .gsub('Minutes', 'Minutos')
        .gsub('Minute', 'Minuto')
        .gsub('Seconds', 'Segundos')
        .gsub('and', 'y')
  end

  def self.active_users
    active_users_list = []
    User.students.each do |student|
      if student.status == "Activo"
        active_users_list << student
      end
    end
    return active_users_list
  end

  def bann!
    update({banned: true})
  end

  def unbann!
    update({banned: false})
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
