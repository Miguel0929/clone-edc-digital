class TemplateRefilable < ActiveRecord::Base
  acts_as_list
  belongs_to :program
  has_many :group_template_refilables
  has_many :groups, through: :group_template_refilables
  has_many :refilables
  has_one :learning_path_content, as: :content, :dependent => :destroy
  has_many :evaluation_refilables

  enum tipo: [ :program, :complementario ]

  validates_presence_of :name, :description, :content
  accepts_nested_attributes_for :evaluation_refilables, reject_if: :all_blank, allow_destroy: true

  def self.tipo_type_options
    [['Ruta de aprendizaje', 'ruta'], ['Complementario', 'complementario']]
  end

  def puntaje(user)
    total_obtenido = 0 
    refilable_references = UserEvaluationRefilable.where(evaluation_refilable_id: EvaluationRefilable.where(template_refilable_id: self.id).pluck(:id)).pluck(:refilable_id).uniq ### NUEVA
    self.evaluation_refilables.each do |rubric|
      #user_eval = rubric.user_evaluation_refilables.find_by(user: user)
      if refilable_references.find{|x|!x.nil?}.nil? ### NUEVA
        user_eval = rubric.user_evaluation_refilables.find_by(user: user)
      else
        last_refilable = Refilable.where(user_id: user.id, template_refilable_id: self.id).order(:created_at).last
        user_eval = rubric.user_evaluation_refilables.find_by(user: user, refilable_id: (last_refilable.id rescue nil))
      end
      unless user_eval.nil?
        total_obtenido += user_eval.puntaje
      end   
    end
    total_obtenido  
  end

  def total_points
    total_puntaje = 0
    self.evaluation_refilables.each do |rubric|
      total_puntaje += rubric.points
    end
    total_puntaje  
  end  
end
