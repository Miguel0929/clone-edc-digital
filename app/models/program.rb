class Program < ActiveRecord::Base
  acts_as_list

  mount_uploader :cover, CoverUploader
  mount_uploader :icon, IconProgramUploader
  mount_uploader :small_cover, SmallCoverUploader

  has_many :chapters, -> { order(position: :asc) }, dependent: :destroy
  has_many :group_programs
  has_many :groups, through: :group_programs
  has_many :program_notifications, dependent: :destroy
  has_many :ratings, as: :ratingable 

  enum tipo: [ :elearning, :construccion ]
  enum level: [:basico, :intermedio, :avanzado]

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
    [['e-learning', 'elearning'], ['Construccion de idea de negocio', 'construccion']]
  end
  def self.level_type_options
    [['Básico', 'basico'], ['Intermedio', 'intermedio'], ['Avanzado', 'avanzado']]
  end
  def self.color_options
    [['Verde', '#67b220'], ['Azul', '#3f5ba3'], ['Coral', '#f46c6c'], ['Amarillo', '#edcf5d'], ['Rosa', '#e83e79'], ['Azul eléctrico', '#7976fb']]
  end

  def get_last_move(thisprogram, current_user)
    current_program = Program.where(id: thisprogram.id).last
    tracker_list = []
    current_program.chapters.each do |chapter|
      chapter.chapter_contents.each do |content|
        content.trackers.each do |tracker|
          if tracker.user_id == current_user.id
            event = tracker
            tracker_list << event
          end
        end
      end
    end
    last_content = tracker_list.sort_by{|m| [m.updated_at].max}.last
    return last_content
  end

  def program_checked?(program, user)
    tracker = []
    Program.find(program.id).chapters.each do |chapter|
      if chapter.chapter_checked?(chapter, user)
        event = 1
      else
        event = 0
      end
      tracker << event
    end
    status = tracker.detect {|i| i == 0}.nil? #si no hay ningún cero en el arreglo @tracker es TRUE
    return status
  end

end
