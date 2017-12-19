class LearningPathProgram < ActiveRecord::Base
  belongs_to :program
  
  def anterior(grupo)
    programas  = grupo.learning_path.learning_path_programs.order(:position)  
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
