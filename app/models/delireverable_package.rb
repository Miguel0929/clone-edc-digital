class DelireverablePackage < ActiveRecord::Base
  has_many :group_delireverable_packages
  has_many :groups, through: :group_delireverable_packages
  has_many :delireverables, :dependent => :delete_all
  has_one :chapter_content, as: :coursable
  has_one :learning_path_content, as: :content, :dependent => :destroy

  validates_presence_of :name, :description
  enum tipo: [ :program, :complementario ]
  def self.tipo_type_options
    [['Ruta de aprendizaje', 'ruta'], ['Complementario', 'complementario']]
  end

  def delireverables_sent(user)
    entregables=self.delireverables
    respuestas=[]
    entregables.each do |entregable|
      unless entregable.delireverable_users.find_by(user: user).nil?
        respuestas.push(entregable.delireverable_users.find_by(user: user))
      end  
    end
   
    if respuestas.length>0
      return true
    else
      return false     
    end   
  end 

    
end
