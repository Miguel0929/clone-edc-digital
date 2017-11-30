class LearningPathContent < ActiveRecord::Base
  belongs_to :learning_path
  belongs_to :content, polymorphic: true

  def model
    content_type.constantize.find_by(id: content_id)
  end

  def anterior(ruta)
    programas  = ruta.learning_path_contents.where(content_type: "Program").order(:position)  
    anterior=Program.new

    programas.each do |p|
      if p.model==self.model
        return anterior
      else
        anterior=p.model
      end  
    end
  end
   
end
