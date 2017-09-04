class TemplateRefilable < ActiveRecord::Base
  acts_as_list
  
  has_many :group_template_refilables
  has_many :groups, through: :group_template_refilables
  has_many :refilables

  enum tipo: [ :ruta, :complementario ]

  validates_presence_of :name, :description, :content

  def self.tipo_type_options
    [['Ruta de aprendizaje', 'ruta'], ['Complementario', 'complementario']]
  end

end
