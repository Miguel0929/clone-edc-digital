class User < ActiveRecord::Base
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks
  acts_as_token_authenticatable

  after_create :create_code
  attr_accessor :agreement
  acts_as_paranoid
  mount_uploader :profile_picture, ProfilePictureUploader
  ROLETYPES = [ ['Estudiante', 'student'], ['Mentor', 'mentor'], ['Administrador', 'admin'], ['Staff', 'staff']]

  enum role: [ :student, :mentor, :admin, :staff ]
  enum gender: [ :male, :female ]
  enum evaluation_status: [:'sin evaluar', :evaluado]
  serialize :tour_trigger, Hash 

  has_many :answers
  has_many :group_users
  has_many :groups, through: :group_users
  has_many :trackers
  has_many :notifications
  has_many :comment_notifications, :through => :notifications, :source => :notificable, :source_type => 'CommentNotification'
  has_many :program_notifications, :through => :notifications, :source => :notificable, :source_type => 'ProgramNotification'
  has_many :shared_group_attachment_notifications, :through => :notifications, :source => :notificable, :source_type => 'SharedGroupAttachmentNotification'
  has_many :learning_path_notifications, :through => :notifications, :source => :notificable, :source_type => 'LearningPathNotification'
  has_many :mentor_program_notifications, :through => :notifications, :source => :notificable, :source_type => 'MentorProgramNotification'
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
  has_many :program_stats, dependent: :destroy
  belongs_to :industry
  has_many :panel_notifications
  has_many :refilables
  has_many :attempts
  has_one :user_code


  devise :database_authenticatable, :recoverable, :invitable, :validatable, :registerable, :omniauthable

  scope :students, -> { where(role: 0) }
  scope :mentors, -> { where(role: 1) }
  scope :staffs, -> { where(role: 3) }
  scope :invitation_accepted, -> { where.not('invitation_accepted_at' => nil) }
  scope :invitation_no_accepted, -> { where('invitation_accepted_at' => nil) }
  scope :search_query, -> (query) {
    where('lower(users.first_name) LIKE lower(?) OR lower(users.last_name) LIKE lower(?) OR lower(users.email) LIKE lower(?)',
         "%#{query}%", "%#{query}%", "%#{query}%")
  }

  validates_presence_of :first_name, :last_name, :phone_number
  validates_acceptance_of :agreement

  belongs_to :group

  before_create :set_origin
  after_create :assign_group
  after_update :del_code

  def self.authenticate(email, password)
    user = find_for_authentication(email: email)

    unless user.nil?
      user.valid_password?(password) ? user : nil
    end
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

  def refilables_answered_for(program)
    program.chapters.joins(template_refilables: [:refilables]).where('refilables.user_id': self.id).count
  end

  def delireverables_answered_for(program)
    arr=[]
    program.chapters.each do |p|
      p.delireverable_packages.each do |d|
        if d.delireverables_sent(self)
          arr.push(d)
        end  
      end  
    end
    return arr.length  
  end

  def quizzes_answered_for(program)
    arr=[]
    program.chapters.each do |p|
      p.quizzes.each do |d|
        if d.answered?(self)
          arr.push(d)
        end  
      end  
    end
    return arr.length  
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
    total_questions = program.chapters.joins(:questions).select('questions.*').count
    (questions_answered_for(program) * 100) / total_questions rescue 0
  end

  def percentage_answered_for(program)
    total_questions = program.chapters.joins(:questions).select('questions.*').count
    total_quizzes = program.chapters.joins(:quizzes).count
    total_delireverables = program.chapters.joins(:delireverable_packages).count
    total_refilables = program.chapters.joins(:template_refilables).count
   
    ((questions_answered_for(program) + delireverables_answered_for(program)+ refilables_answered_for(program) + quizzes_answered_for(program)) * 100) / (total_questions + total_quizzes + total_delireverables + total_refilables) rescue 0
  end

  def answered_questions_percentage
    return 0 if group.nil?

    total_of_answers = group.all_programs.joins(chapters: [questions: [:answers]]).where('answers.user_id': self.id).count
    total_of_questions = group.all_programs.joins(chapters: [:questions]).select('questions.*').count

    ((total_of_answers.to_f * 100) / total_of_questions.to_f).round(2) rescue 0
  end

  def content_visited_percentage
    return 0 if group.nil?

    total_of_visited_contents = trackers.joins(chapter_content: [chapter: [:program]]).where("chapter_contents.coursable_type = 'Lesson' AND programs.id in (?)", group.all_programs.pluck(:id)).count
    total_of_contents = group.all_programs.joins(chapters: [:chapter_contents]).where("chapter_contents.coursable_type = 'Lesson'").count

    ((total_of_visited_contents.to_f * 100) / total_of_contents.to_f).round(2) rescue 0
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
    return 'No ha iniciado sesión' if sessions.last.nil?

    if TimeDifference.between(sessions.last.finish, Time.now).humanize.nil?
      "Menos de 1 segundo"
    else
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

  def day
    self.invitation_created_at.strftime('%Y-%m-%d')
  end

  def ready_to_check?
    groupstats = self.group.all_programs.map{ |program| program.program_stats.find_by(user_id: self.id)}
    stats = groupstats.map{ |n| if !n.nil? then n.checked else 0 end} #Regresa el valor de checked de los programa_stats (1 o 0), si no existe un program_stat (n.nil?) entonces pone 0
    detection = stats.detect { |i| i == 0}.nil? #Si no halla ningún 0 dará true al preguntar .nil?, o sea que todos los programas de este usuario han sido "checked"
    if detection == false then self.update(evaluation_status: 0) end #Si detecta algún 0 en 'detection' entonces regresa a 'no evaluado' al usuario
    return detection
  end

  def get_update_move
    program_update = ProgramStat.where(user_id: self.id)
    last_content = program_update.sort_by{|m| [m.updated_at].max}.last(1)
    return last_content
  end

  def get_last_program
    last_stat = self.program_stats.sort_by{ |stat| [stat.updated_at].max}.last
    last_program = Program.where(id: last_stat.program_id).last
  end

  def has_answer_refilable?(template_refilable)
    !template_refilable.refilables.find_by(user: self).nil?
  end
  def has_sent_delireverables?(delireverable_package)
    entregables=delireverable_package.delireverables
    respuestas=[]
    entregables.each do |entregable|
      unless entregable.delireverable_users.find_by(user: self).nil?
        respuestas.push(entregable.delireverable_users.find_by(user: self))
      end  
    end
   
    if respuestas.length>0
      return true
    else
      return false     
    end  
  end
  def has_answer_quiz?(quiz)
    ids = quiz.quiz_questions.map { |q| q.id }
    respuestas = QuizAnswer.where(quiz_question_id: ids, user_id: self.id).count
    preguntas=quiz.quiz_questions.count
    if respuestas > 0 && preguntas != 0
      return true
    else
      return false
    end  
  end  

  def total_quizzes
    self.group.quizzes.count
  end

  def answered_quizzes
    total = 0
    results = []
    self.group.quizzes.each do |quiz|
      if quiz.answered(self) > 0 
        total += 1
        results.push( (quiz.average(self).to_f / quiz.total_points.to_f * 100).ceil )
      end
    end
    average = results.inject(0.0) { |sum, el| sum + el } / results.size
    if average.nan? then average = 0 end
    return average, total
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

  def create_code
    if self.user_code.nil?
      unique = true
      codigo = SecureRandom.hex(6) 
      while unique
        if UserCode.find_by(codigo: codigo).nil?
          UserCode.create(codigo: codigo, user: self)
          unique = false
        else
          codigo = SecureRandom.hex(6)
        end
      end
    end
  end

  def del_code
    unless self.invitation_accepted_at.nil?
      unless self.user_code.nil?   
        self.user_code.destroy
      end  
    end  
  end

end
