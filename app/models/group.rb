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
  has_many :shared_group_attachment_groups
  has_many :shared_group_attachments, through: :shared_group_attachment_groups
  has_one :group_stats
  has_many :delireverable_packages, through: :group_delireverable_packages
  has_many :template_refilables, through: :group_template_refilables
  has_many :group_delireverable_packages
  has_many :group_template_refilables
  belongs_to :state
  belongs_to :university
  belongs_to :learning_path
  belongs_to :learning_path2, class_name: "LearningPath"

  validates_presence_of :name, :key
  validates_uniqueness_of :key

  scope :group_search, -> (query) {
    where('lower(groups.name) LIKE lower(?) OR lower(groups.key) LIKE lower(?)',
         "%#{query}%", "%#{query}%")
  }

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
    self.learning_path.nil? ? fisica_quizzes = [] : fisica_quizzes = self.learning_path.learning_path_contents.where(content_type: "Quiz").pluck(:content_id)
    self.learning_path2.nil? ? moral_quizzes = [] : moral_quizzes = self.learning_path2.learning_path_contents.where(content_type: "Quiz").pluck(:content_id)
    aux = group_quizzes + fisica_quizzes + moral_quizzes
    Quiz.where(id: aux)
  end

  def all_refilables
    group_refilables = self.template_refilables.pluck(:id)
    self.learning_path.nil? ? fisica_refilables = [] : fisica_refilables = self.learning_path.learning_path_contents.where(content_type: "TemplateRefilable").pluck(:content_id)
    self.learning_path2.nil? ? moral_refilables = [] : moral_refilables = self.learning_path2.learning_path_contents.where(content_type: "TemplateRefilable").pluck(:content_id)
    aux = group_refilables + fisica_refilables + moral_refilables
    TemplateRefilable.where(id: aux)
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
end
