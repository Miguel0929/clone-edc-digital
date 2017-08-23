class LearningPathContent < ActiveRecord::Base
  belongs_to :learning_path
  belongs_to :content, polymorphic: true
  
  def model
    content_type.constantize.find_by(id: content_id)
  end
  def anterior
  	def anterior(grupo)
    ids = grupo.programs.ruta.map{|p|p.id}  
    programas = grupo.group_programs.where(program_id: ids).order(:position)
    anterior=Program.new
    programas.each do |p|
      if p.program==self.program
        return anterior
      else
        anterior=p.program
      end
    end
  end	
  end	
end
