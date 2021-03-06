class User < ActiveRecord::Base
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks
  acts_as_token_authenticatable

  nilify_blanks :only => [:bio, :city, :state, :situation, :interest, :challenge, :goal]
  after_create :create_code
  attr_accessor :agreement
  acts_as_paranoid
  mount_uploader :profile_picture, ProfilePictureUploader
  ROLETYPES = [ ['Estudiante', 'student'], ['Mentor', 'mentor'], ['Profesor', 'profesor'],['Administrador', 'admin'], ['Staff', 'staff']]

  enum role: [ :student, :mentor, :admin, :staff, :profesor ]
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
  has_many :refilable_notifications, :through => :notifications, :source => :notificable, :source_type => 'RefilableNotification'
  has_many :shared_group_attachment_notifications, :through => :notifications, :source => :notificable, :source_type => 'SharedGroupAttachmentNotification'
  has_many :learning_path_notifications, :through => :notifications, :source => :notificable, :source_type => 'LearningPathNotification'
  has_many :mentor_program_notifications, :through => :notifications, :source => :notificable, :source_type => 'MentorProgramNotification'
  has_many :mentor_question_notifications, :through => :notifications, :source => :notificable, :source_type => 'MentorQuestionNotification'
  has_many :visits
  has_many :events, class_name: 'Ahoy::Event'
  has_many :comments
  has_many :user_evaluations
  has_many :user_evaluation_refilables
  has_many :evaluations, through: :user_evaluations
  has_many :evaluation_refilables, through: :user_evaluation_refilables
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
  has_many :user_trackers
  belongs_to :coach, :class_name => "User", foreign_key: "coach_id"
  has_many :user_trainees
  has_many :trainees, through: :user_trainees, :foreign_key => "trainee_id"
  has_one :user_detail

  devise :database_authenticatable, :recoverable, :invitable, :validatable, :registerable, :omniauthable

  scope :students, -> { where(role: 0) }
  scope :mentors, -> { where(role: 1) }
  scope :profesors, -> { where(role: 4) }
  scope :staffs, -> { where(role: 3) }
  scope :invitation_accepted, -> { where.not('invitation_accepted_at' => nil) }
  scope :invitation_no_accepted, -> { where('invitation_accepted_at' => nil) }
  scope :search_query, -> (query) {
    where('lower(users.first_name) LIKE lower(?) OR lower(users.last_name) LIKE lower(?) OR lower(users.email) LIKE lower(?)',
         "%#{query}%", "%#{query}%", "%#{query}%")
  }

  validates_presence_of :first_name, :last_name, :phone_number, :group_id
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
    questions = program.all_questions.pluck(:id)
    Answer.where(question_id: questions, user_id: self.id).count
    #program.chapters.joins(questions: [:answers]).where('answers.user_id': self.id).count
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

  def set_all_program_stats
    if self.group != nil
      self.group.all_programs.each do |program|
        p_stats = self.program_stats.find_by(program_id: program)
        progress = self.percentage_questions_answered_for(program).to_f
        seen = self.percentage_content_visited_for(program).to_f
        if p_stats.nil?
          ProgramStat.create(user_id: self.id, program_id: program.id, program_progress: progress, program_seen: seen)
        else
          p_stats.update(program_progress: progress, program_seen: seen)
        end
      end
    end
  end

  def percentage_content_visited_for(program)
    total = program.chapters.joins(:lessons).select('lessons.*').count
    (content_visted_for(program) * 100) / total rescue 0
  end

  def percentage_questions_answered_for(program)
    total_questions = program.all_questions_count
    (questions_answered_for(program) * 100) / total_questions rescue 0
  end

  def percentage_answered_for(program)
    total_questions = program.all_questions_count
    
    (questions_answered_for(program) * 100) / (total_questions) rescue 0
  end

  def integral_percentage_progress_for(program)
    program_stat = self.program_stats.find_by(program_id: program)
    if program_stat.nil? #Primero busca porgram_stat y si no est?? lo calcula
      return self.percentage_questions_answered_for(Program.find(program))
    else
      return program_stat.program_progress
    end
  end

  def integral_percentage_visited_for(program)
    program_stat = self.program_stats.find_by(program_id: program)
    if program_stat.nil? #Primero busca porgram_stat y si no est?? lo calcula
      prog = Program.find(program)
      return self.percentage_content_visited_for(prog)
    else
      return program_stat.program_seen
    end
  end

  def overall_percentage_answered_for(program)
    #calcular preguntas
    total_questions = program.chapters.joins(:questions).select('questions.*').count
    answered_questions = questions_answered_for(program)
    #calcular ex??menes
    total_quizzes = program.quizzes.count
    answered_quizzes = program.answered_quizzes(self)
    #calcular plantillas
    refilables = program.template_refilables.pluck(:id)
    total_refilables = refilables.count
    answered_refilables = Refilable.where(template_refilable_id: refilables, user_id: self).count
    if (total_questions + total_quizzes + total_refilables) > 0
      return ((answered_questions + answered_quizzes + answered_refilables) * 100) / (total_questions + total_quizzes + total_refilables)
    else
      return 0
    end
  end

  def answered_questions_percentage
    return 0 if group.nil?
    #self.user_progress
    #total_of_answers = group.all_programs.joins(chapters: [questions: [:answers]]).where('answers.user_id': self.id).count
    #total_of_questions = group.all_programs.joins(chapters: [:questions]).select('questions.*').count
    total_of_answers = 0; total_of_questions = 0; preguntas = []
    all_programs = group.all_programs
    all_programs.each{|program| total_of_questions += program.all_questions_count}
    all_programs.each{|program| preguntas << program.all_questions.pluck(:id)}
    total_of_answers = Answer.where(user_id: self.id, question: preguntas).count
    return 0 if (total_of_answers == 0 && total_of_questions == 0) || (total_of_answers != 0 && total_of_questions == 0)

    ((total_of_answers.to_f * 100) / total_of_questions.to_f).round(2) rescue 0
  end

  def content_visited_percentage
    return 0 if group.nil?
    #self.user_seen
    all_programs = group.all_programs
    total_of_visited_contents = trackers.joins(chapter_content: [chapter: [:program]]).where("chapter_contents.coursable_type = 'Lesson' AND programs.id in (?)", all_programs.pluck(:id)).count
    total_of_contents = all_programs.joins(chapters: [:chapter_contents]).where("chapter_contents.coursable_type = 'Lesson'").count
    total_of_visited_contents = trackers.joins(chapter_content: [chapter: [:program]]).where("programs.id in (?)", all_programs.pluck(:id)).count
    total_of_contents = all_programs.joins(chapters: [:chapter_contents]).count

    return 0 if (total_of_visited_contents == 0 && total_of_contents == 0) || (total_of_visited_contents != 0 && total_of_contents == 0)

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
    return 'No ha iniciado sesi??n' if sessions.last.nil?

    if TimeDifference.between(sessions.last.finish, Time.now).humanize.nil?
      "Menos de 1 segundo"
    else
      TimeDifference.between(sessions.last.finish, Time.now)
          .humanize
          .gsub('Years', 'A??o')
          .gsub('Months', 'Meses')
          .gsub('Weeks', 'Semanas')
          .gsub('Week', 'Semana')
          .gsub('Days', 'D??as')
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
    detection = stats.detect { |i| i == 0}.nil? #Si no halla ning??n 0 dar?? true al preguntar .nil?, o sea que todos los programas de este usuario han sido "checked"
    if detection == false then self.update(evaluation_status: 0) end #Si detecta alg??n 0 en 'detection' entonces regresa a 'no evaluado' al usuario
    return detection
  end

  def get_update_move
    program_update = ProgramStat.where(user_id: self.id)
    last_content = program_update.sort_by{|m| [m.updated_at].max}.last(1)
    return last_content
  end

  def get_last_program
    last_stat = self.program_stats.sort_by{ |stat| [stat.updated_at].max}.last
    if last_stat.nil?
      return nil
    else
      return Program.where(id: last_stat.program_id).last
    end
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
    self.group.all_quizzes.count
  end

  def answered_quizzes
    total = 0
    results = []
    if !self.group.nil?
      self.group.all_quizzes.each do |quiz|
        if quiz.answered(self) > 0 
          total += 1
          results.push( (quiz.average(self).to_f / quiz.total_points.to_f * 100).ceil )
        end
      end
    end
    average = results.inject(0.0) { |sum, el| sum + el } / results.size
    if average.nan? then average = 0 end
    return average, total
  end

  def get_program_stat(program)
    self.program_stats.find_by(program_id: program)
  end

  def user_groups
    if self.admin?
      Group.all
    elsif self.mentor? || self.profesor?
      self.groups
    else
      nil
    end
  end

  def overall_percentage_answered_for(program)
    #calcular preguntas
    total_questions = program.all_questions.count
    answered_questions = questions_answered_for(program)
    #calcular ex??menes
    total_quizzes = program.quizzes.count
    answered_quizzes = program.answered_quizzes(self)
    #calcular plantillas
    refilables = program.template_refilables.pluck(:id)
    total_refilables = refilables.count
    answered_refilables = Refilable.where(template_refilable_id: refilables, user_id: self).count
    if (total_questions + total_quizzes + total_refilables) > 0
      return ((answered_questions + answered_quizzes + answered_refilables) * 100) / (total_questions + total_quizzes + total_refilables)
    else
      return 0
    end
  end

  def program_progress_intercom(p_id)
    if !Program.where(id: p_id).empty?
      program = Program.find(p_id)
      #calcular preguntas
      total_questions = program.chapters.joins(:questions).select('questions.*').count
      answered_questions = questions_answered_for(program)
      #calcular ex??menes
      total_quizzes = program.quizzes.count
      answered_quizzes = program.answered_quizzes(self)
      #calcular plantillas
      refilables = program.template_refilables.pluck(:id)
      total_refilables = refilables.count
      answered_refilables = Refilable.where(template_refilable_id: refilables, user_id: self).count
      if (total_questions + total_quizzes + total_refilables) > 0
        return ((answered_questions + answered_quizzes + answered_refilables) * 100) / (total_questions + total_quizzes + total_refilables)
      else
        return 0
      end
    else
      return 0
    end
  end

  def total_time_hours
    tt = self.total_time
    return 0 if tt == 0
    return (tt / 60).round.to_s + " h " + (tt % 60).round.to_s + " min"
  end

  def visits_per_week
    return 0 if visits.last.nil?
    per_week = visits.group("DATE_TRUNC('week', started_at)").count.map{|v| v[1]}
    return per_week.inject(0){|sum,x| sum + x } / per_week.count
  end

  def physical_route
    if group.nil?
      return "Sin grupo"
    else 
      return group.learning_path.nil? ? "Sin ruta f??sica" : group.learning_path.name
    end
  end  

  def moral_route
    if group.nil?
      return "Sin grupo"
    else 
      return group.learning_path2.nil? ? "Sin ruta moral" : group.learning_path2.name  
    end
  end

  def program_stats_string
    if group.nil?
      return "Sin grupo"
    else 
      user_p = group.all_programs.pluck(:id) 
      user_s = program_stats.where(program_id: user_p).pluck(:program_id, :program_progress, :program_seen, :checked)
      if user_s.empty?
        return "Sin avances"
      else
        return user_s.map{|us| Program.find(us[0]).short_name + " (prog: " + us[1].to_s + "%" + ", visto: " + us[2].to_s + "%, " + (us[3]==1 ? "evaluado)" : "no evaluado)") }
      end
    end
  end  

  def number_answered_quizzes
    if group.nil?
      return "Sin grupo"
    else 
      quizzes = group.all_quizzes
      if quizzes.empty?
        return "Sin evaluaciones"
      else
        return quizzes.map{|q| (q.answered(self)>0)}.count(true).to_s + " de " + quizzes.count.to_s
      end
    end
  end 

  def number_answered_refilables
    if group.nil?
      return "Sin grupo"
    else 
      t_refilables = group.all_refilables
      if t_refilables.empty?
        return "Sin plantillas"
      else
        return t_refilables.map{|r| r.refilables.find_by(user: self).nil?}.count(false).to_s + " de " + t_refilables.count.to_s
      end
    end
  end 

  def intercom_prog_status(pid)
    stat = self.program_stats.find_by(program_id: pid)
    if stat.nil?
      return "No inscrito"
    else
      return (stat.checked == 0 ? "Sin evaluar" : "Evaluado")
    end
  end

  def intercom_prog_quizzes(pid)
    if group.nil?
      return 0
    else 
      quizzes = self.group.all_quizzes.where(program_id: pid)
      if quizzes.empty?
        return 0
      else
        if quizzes.map{|q| (q.answered(self)>0)}.count(true) < quizzes.count
          return 0
        else
          results = []
          quizzes.map{|q| results.push( (q.average(self).to_f / q.total_points.to_f * 100).ceil )}
          average = results.inject(0.0) { |sum, el| sum + el } / results.size
          return (average.nan? ? 0 : average.ceil)
        end
      end
    end
  end

  def intercom_prog_refillables(pid)
    if group.nil?
      return "Sin grupo"
    else 
      refilables = self.group.all_refilables.where(program_id: pid)
      if refilables.empty?
        return "Sin plantillas"
      else
        return refilables.map{|r| r.refilables.find_by(user: self).nil?}.count(false).to_s + " de " + refilables.count.to_s
      end
    end
  end

  def intercom_prog_seen(pid)
    stat = self.program_stats.find_by(program_id: pid)
    return (stat.nil? ? 0 : stat.program_seen.ceil)
  end

  def intercom_prog_answered(pid)
    stat = self.program_stats.find_by(program_id: pid)
    return (stat.nil? ? 0 : stat.program_progress.ceil)
  end

  def intercom_activation_code
    if invitation_accepted_at.nil?
      if user_code.nil? then create_code end
      return user_code.codigo
    else
      return "No aplica"
    end
  end

  def profile_info_status
    if (state.nil? || state.empty?) || (city.nil? || city.empty?) || gender.nil? || industry_id.nil? || (self.user_detail.nil? || (self.user_detail.birthdate.nil? || self.user_detail.situation.nil? || self.user_detail.interest.nil? || self.user_detail.challenge.nil? || self.user_detail.goal.nil? ))
      return "Incompleto"
    else
      return "Completo"
    end
  end

  def gender_output
    if !gender.nil? then return (gender == "male" ? "Hombre" : "Mujer") end
  end

  def age
    if !self.user_detail.nil?
      if !self.user_detail.birthdate.nil?
        bd, d = self.user_detail.birthdate, Date.today
        y = d.year - bd.year 
        y = y - 1 if (
             bd.month >  d.month or 
            (bd.month >= d.month and bd.day > d.day)
        )
        return y
      end 
    end
  end

  def evaluation_result_for(chapter)
    #Este m??todo est?? basado en el que aparece en mentor/evaluations_controller.rb llamado 'evaluation_result(chapter)'
    evaluation_points =  UserEvaluation.where(user_id: self, evaluation_id: chapter.evaluations.pluck(:id)).pluck(:points).inject(0){|sum,x| sum + x }
    total_evaluations_points = Evaluation.where(chapter_id: chapter).count * 100
    (((evaluation_points * 100) / 800 rescue 0) * chapter.points / 100)
  end

  def my_student?(mentor)
    student = self.group.nil? ? false : mentor.groups.pluck(:id).include?(self.group.id)
    trainee = self.coach.nil? ? false : (self.coach.id == mentor.id)
    return (student || trainee)
  end

  def user_program_refilables_count(template_refilables)
    total = 0
    template_refilables.each do |refil|
      rubricas = refil.evaluation_refilables.pluck(:id)
      revisiones = UserEvaluationRefilable.where(evaluation_refilable_id: rubricas, user_id: self.id).count
      if rubricas.length == revisiones && rubricas.length > 0
        total+=1
      end  
    end 
    total 
  end

  def user_program_refilables_avg(template_refilables)
    total = 0
    c_template_refilables = 0
    template_refilables.each do |refil|
      if refil.evaluation_refilables.count > 0
        c_template_refilables += 1
        total += refil.last_calification(self)
      end
=begin      
      rubricas = refil.evaluation_refilables.pluck(:id)
      revisiones_c = UserEvaluationRefilable.where(evaluation_refilable_id: rubricas, user_id: self.id).count
      rubricas = UserEvaluationRefilable.where(evaluation_refilable_id: rubricas, user_id: self.id)
      revisiones = 0
      rubricas.each do |rev|
        total_puntos = rev.evaluation_refilable.points
        puntaje = rev.puntaje

        revisiones += (puntaje*100)/total_puntos rescue 0
      end  

      promedio = revisiones/(revisiones_c) rescue 0 
      if rubricas.length == revisiones_c && rubricas.length > 0
        total+=promedio
      end
=end        
    end 
    total/c_template_refilables rescue 0
  end

  def refilable_permitted?(template_refilable_id)
    program = TemplateRefilable.find(template_refilable_id).program
    if program.nil?
      true
    else
      total_questions = program.all_questions_count
      if total_questions == 0
        self.integral_percentage_visited_for(program.id) > 95.0
      else
        self.integral_percentage_progress_for(program.id) > 95.0 && self.integral_percentage_visited_for(program.id) > 95.0
      end
    end
  end

  private

  def set_origin
    self.state = 'Ciudad de M??xico'
    self.city = 'Ciudad de M??xico'
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
