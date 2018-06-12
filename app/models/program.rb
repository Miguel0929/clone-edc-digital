class Program < ActiveRecord::Base
  acts_as_list
  acts_as_paranoid

  mount_uploader :cover, CoverUploader
  mount_uploader :icon, IconProgramUploader
  mount_uploader :small_cover, SmallCoverUploader

  has_many :chapters, -> { order(position: :asc) }, dependent: :destroy
  has_many :group_programs, dependent: :destroy
  has_many :groups, through: :group_programs
  has_many :program_notifications, dependent: :destroy
  has_many :ratings, as: :ratingable 
  has_many :program_stats, dependent: :destroy
  has_many :quizzes
  has_many :template_refilables
  has_one :learning_path_content, as: :content, :dependent => :destroy
  has_many :program_actives, :dependent => :destroy
  has_one :score_student_stat
  has_one :student_evaluated
  has_many :program_attachments 

  enum tipo: [ :elearning, :construccion, :fusion ]
  enum level: [:basico, :intermedio, :avanzado]
  enum content_type: [:ruta, :complementario, :powered]

  validates_presence_of :name, :description, :cover

  def next_content_for(user)
    chapter_contents_visited = user.trackers.map(&:chapter_content)
    chapter_contents = chapters.map { |chapter| chapter.chapter_contents}.flatten
    next_content = chapter_contents.find { |chapter_content| !chapter_contents_visited.include?(chapter_content) }

    next_content.nil? ? [:dashboard, self] : [:dashboard, next_content]
  end

  def next_chapter(chapter)
    chapters.where("position > ?", chapter.position).first
  end

  def rating
    r=self.ratings.average(:rank)
    if r.nil?
      return 0.0
    else
      return r
    end
  end

  def self.category_type_options
    [['Selecciona una categoría', 'none'], ['Cursos principales', 'main'], ['Cursos adicionales', 'additional'], ['Cursos externos', 'external']]
  end
  def self.tipo_type_options
    [['e-learning', 'elearning'], ['Construccion de idea de negocio', 'construccion'], ['Fúsion', 'fusion']]
  end
  def self.level_type_options
    [['Básico', 'basico'], ['Intermedio', 'intermedio'], ['Avanzado', 'avanzado']]
  end
  def self.color_options
    [['Verde', '#67b220'], ['Azul', '#3f5ba3'], ['Coral', '#f46c6c'], ['Amarillo', '#edcf5d'], ['Rosa', '#e83e79'], ['Azul eléctrico', '#7976fb']]
  end
  def self.content_type_options
    [['Ruta EDC', 'ruta'], ['Complementario', 'complementario'], ['Powered by ( Brindado por terceros)','powered']]
  end

  def get_last_move(current_user)
    Tracker.where(chapter_content_id: ChapterContent.where(chapter_id: chapters.pluck(:id)).pluck(:id)).where(user_id: current_user).order(updated_at: :asc).last
  end

  def program_checked?(program, user)
    thisprogram = ProgramStat.where(user_id: user, program_id: program).last
    if thisprogram.nil?
      status = false
    else
      if thisprogram.checked == 1
        status = true
      else
        status = false
      end
    end
    return status
  end

  def alias
    arr=self.name.split(" ")
    return self.name[0,3]+"."+arr[1][0].capitalize+"."+self.id.to_s
  end

  def anterior(learning_path)
    programas  = learning_path.learning_path_contents.where(content_type: "Program").order(:position)  
    anterior=Program.new
    programas.each do |p|
      if p.model==self
        return anterior
      else
        anterior=p.model
      end
    end
  end

  def questions?
    c = 0  
    self.chapters.each do |chapter|
      c += chapter.all_questions.count 
    end
    c == 0 ? false : true 
  end 

  def all_questions_count
    questions = 0
    self.chapters.each do |chapter|
      questions += chapter.all_questions.count 
    end  
    questions
  end

  def all_questions
    questions = []
    self.chapters.each do |chapter|
      chapter.chapter_contents.each do |chapter_content|
        if chapter_content.coursable_type == "Question"
          questions << chapter_content.model.id
        elsif chapter_content.coursable_type == "Chapter" 
          questions += chapter_content.model.questions.pluck(:id)   
        end  
      end
    end
    q = Question.where(id: questions)
  end  

  def all_groups(user)
    program_groups = self.groups.pluck(:id)
    path_content = self.learning_path_content
    if path_content.nil?
      path_groups = []
    else
      l_paths = LearningPath.joins(:learning_path_contents).where(:learning_path_contents => {content_id: self.id, content_type: "Program"}).pluck(:id)
      path_groups = Group.joins(:learning_path).where(:learning_paths => {id: l_paths}).pluck(:id)
      #(path_content.respond_to? :learning_path) ? fisica_groups = path_content.learning_path.groups.pluck(:id) : fisica_groups = []
      #(path_content.respond_to? :learning_path2) ? moral_groups = path_content.learning_path2.groups.pluck(:id) : moral_groups = []
    end
    aux = program_groups + path_groups
    groups = Group.where(id: aux)
    (user.mentor? || user.profesor?) ? groups.where(id: user.groups.pluck(:id)) : groups
  end 

  def answered_quizzes(user)
    ebi = quizzes.map{|q| q.answered(user)}
    return (ebi.size - ebi.count(0))
  end

  def percentage_answered_quizzes(user)
    total_quizzes = quizzes.count
    solved_quizzes = answered_quizzes(user)
    percentage = (solved_quizzes * 100) / total_quizzes rescue 0
    return [solved_quizzes, total_quizzes, percentage]
    #return [total_quizzes, solved_quizzes, (solved_quizzes * 100) / total_quizzes rescue 0]
  end

  def percentage_answered_template_refillables(user)
    refilables = template_refilables.pluck(:id)
    total_refilables = refilables.count
    answered_refilables = Refilable.where(template_refilable_id: refilables, user_id: user.id).count
    percentage = (answered_refilables * 100) / total_refilables rescue 0
    return [answered_refilables, total_refilables, percentage]
    #return [total_refilables, answered_refilables, (answered_refilables * 100) / total_refilables rescue 0]
  end

  def points_earned(user)
    puntos = 0
    self.chapters.each do |chapter|
      puntos += chapter.points_earned(user)
    end
    puntos
  end

  def total_points
    puntos = 0
    self.chapters.each do |chapter|
      puntos += chapter.total_points
    end
    puntos  
  end  

  def evaluated_avg(user)
    total = self.total_points.to_f
    if total == 0
      0
    else
      ((self.points_earned(user).to_f * 100) / self.total_points.to_f)
    end  
  end 
end

