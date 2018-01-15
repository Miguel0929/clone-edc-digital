class Program < ActiveRecord::Base
  acts_as_list

  mount_uploader :cover, CoverUploader
  mount_uploader :icon, IconProgramUploader
  mount_uploader :small_cover, SmallCoverUploader

  has_many :chapters, -> { order(position: :asc) }, dependent: :destroy
  has_many :group_programs, dependent: :destroy
  has_many :groups, through: :group_programs
  has_many :program_notifications, dependent: :destroy
  has_many :ratings, as: :ratingable 
  has_many :program_stats, dependent: :destroy
  has_one :learning_path_content, as: :content, :dependent => :destroy

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

  def anterior(grupo)
    programas  = grupo.learning_path.learning_path_contents.where(content_type: "Program").order(:position)  
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
      c += chapter.questions.count 
    end
    c == 0 ? false : true 
  end 

  def all_groups
    program_groups = self.groups.pluck(:id)
    path_content = self.learning_path_content
    if path_content.nil?
      fisica_groups, moral_groups = [], []
    else
      (path_content.respond_to? :learning_path) ? fisica_groups = path_content.learning_path.groups.pluck(:id) : fisica_groups = []
      (path_content.respond_to? :learning_path2) ? moral_groups = path_content.learning_path2.groups.pluck(:id) : moral_groups = []
    end
    aux = program_groups + fisica_groups + moral_groups
    Group.where(id: aux)
  end 
end
