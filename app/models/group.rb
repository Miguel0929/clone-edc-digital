class Group < ActiveRecord::Base
  acts_as_paranoid

  has_many :group_programs
  has_many :group_users
  has_many :group_quizzes, dependent: :nullify
  has_many :programs, through: :group_programs
  has_many :users, through: :group_users, validate: false
  has_many :quizzes, through: :group_quizzes, dependent: :nullify
  has_many :students, -> { students }, class_name: 'User', foreign_key: 'group_id'
  has_many :active_students, -> { where('invitation_accepted_at IS NOT NULL and role = 0')}, class_name: 'User', foreign_key: 'group_id'
  has_many :active_mentors, -> { where('invitation_accepted_at IS NOT NULL and role = 1')}, class_name: 'User', foreign_key: 'group_id'
  has_many :shared_group_attachment_groups
  has_many :shared_group_attachments, through: :shared_group_attachment_groups
  has_one :group_stat
  has_many :delireverable_packages, through: :group_delireverable_packages
  has_many :template_refilables, through: :group_template_refilables
  has_many :group_delireverable_packages
  has_many :group_template_refilables
  belongs_to :state
  belongs_to :university
  belongs_to :learning_path
  belongs_to :learning_path2, class_name: "LearningPath"
  has_one :reception
  has_one :program_sequence

  validates_presence_of :name, :key
  validates_uniqueness_of :key

  scope :group_search, -> (query) {
    where('lower(groups.name) LIKE lower(?) OR lower(groups.key) LIKE lower(?)',
         "%#{query}%", "%#{query}%")
  }

  has_many :inactive_students, -> { where('invitation_accepted_at IS NULL and role = 0')}, class_name: 'User', foreign_key: 'group_id'

  def student_search(query) 
    active_students.where('lower(users.first_name) LIKE lower(?) OR lower(users.last_name) LIKE lower(?) OR lower(users.email) LIKE lower(?)',
                         "%#{query}%", "%#{query}%", "%#{query}%") 
  end

  def get_group_stat(group)
    GroupStat.find_by(group_id: group.id)
  end

  def all_programs
    group_programs = self.programs.pluck(:id)
    self.learning_path.nil? ? fisica_programs = [] : fisica_programs = self.learning_path.learning_path_contents.where(content_type: "Program").pluck(:content_id)
    self.learning_path2.nil? ? moral_programs = [] : moral_programs = self.learning_path2.learning_path_contents.where(content_type: "Program").pluck(:content_id)
    aux = group_programs + fisica_programs + moral_programs
    Program.where(id: aux)
  end

  def all_quizzes
    group_quizzes = self.quizzes.pluck(:id)
    self.learning_path.nil? ? fisica_quizzes = [] : fisica_quizzes = self.learning_path.learning_path_contents.where(content_type: "Program")
    self.learning_path2.nil? ? moral_quizzes = [] : moral_quizzes = self.learning_path2.learning_path_contents.where(content_type: "Program")
    fisica_quizzes.sort_by &:position
    moral_quizzes.sort_by &:position
    active_elements = []
    fisica_quizzes.each do |lp|
      Quiz.where(program_id: lp.content_id).each do |element| active_elements << element.id end
    end
    moral_quizzes.each do |lp|
      Quiz.where(program_id: lp.content_id).each do |element| active_elements << element.id end
    end
    active_elements = group_quizzes + active_elements
    Quiz.where(id: active_elements).sort_by{ |x| active_elements.index(x.id) }
  end

  def all_refilables
    group_refilables = self.template_refilables.pluck(:id)
    self.learning_path.nil? ? fisica_refilables = [] : fisica_refilables = self.learning_path.learning_path_contents.where(content_type: "Program")
    self.learning_path2.nil? ? moral_refilables = [] : moral_refilables = self.learning_path2.learning_path_contents.where(content_type: "Program")
    fisica_refilables.sort_by &:position
    moral_refilables.sort_by &:position
    active_elements = []
    fisica_refilables.each do |lp|
      TemplateRefilable.where(program_id: lp.content_id).each do |element| active_elements << element.id end
    end
    moral_refilables.each do |lp|
      TemplateRefilable.where(program_id: lp.content_id).each do |element| active_elements << element.id end
    end
    active_elements = group_refilables + active_elements
    TemplateRefilable.where(id: active_elements).sort_by{ |x| active_elements.index(x.id) }
  end

  def all_delireverables
    ids_g = []; ids_f = []; ids_m = [] 
    self.learning_path.nil? ? fisica_delireverables = [] : fisica_delireverables = self.learning_path.learning_path_contents.where(content_type: "DelireverablePackage")
    self.learning_path2.nil? ? moral_delireverables = [] : moral_delireverables = self.learning_path2.learning_path_contents.where(content_type: "DelireverablePackage")    
    ids_g  = Delireverable.joins(delireverable_package: [:groups])
                                    .where('groups.id = ?', self.id)
                                    .order(position: :asc).pluck(:id)
    fisica_delireverables.each do |package|
      package.model.delireverables.each do |delireverable|
        ids_f << delireverable.id
      end  
    end

    moral_delireverables.each do |package|
      package.model.delireverables.each do |delireverable|
        ids_m << delireverable.id
      end  
    end 
    aux = ids_g + ids_f + ids_m
    Delireverable.where(id: aux)
  end

  def programs_complementaries
    group_programs = self.programs.pluck(:id)
    self.learning_path.nil? ? fisica_programs = [] : fisica_programs = self.learning_path.learning_path_contents.where(content_type: "Program").pluck(:content_id)
    self.learning_path2.nil? ? moral_programs = [] : moral_programs = self.learning_path2.learning_path_contents.where(content_type: "Program").pluck(:content_id)
    aux = group_programs - (fisica_programs + moral_programs)
    Program.where(id: aux)
  end

  def answered_quizzes
    total = 0
    contestados = 0
    quizzes = self.all_quizzes

    quizzes.each do |quiz|
      self.students.each do |student|
        total = total + 1
        if quiz.answered?(student)
          contestados = contestados + 1
        end        
      end  
    end

    if total == 0 then average = 0 else average = (contestados * 100) / (total) end  
    return average, contestados
  end

  def answered_refilables
    total = 0
    contestados = 0
    refilables = self.all_refilables

    refilables.each do |refilable|
      self.students.each do |student|
        total = total + 1
        con = Refilable.where(template_refilable: refilable, user: student).count
        if con > 0
          contestados = contestados + 1
        end        
      end  
    end

    if total == 0 then average = 0 else average = (contestados * 100) / (total) end  
    return average, contestados
  end

  def active_students
    self.students.where.not(invitation_accepted_at: nil)
  end

  def inactive_students
    self.students.where(invitation_accepted_at: nil)
  end

  def my_group?(mentor)
    self.users.pluck(:id).include?(mentor.id)
  end
end
