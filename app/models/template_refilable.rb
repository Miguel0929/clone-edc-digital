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

end
