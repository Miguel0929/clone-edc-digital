class GroupProgram < ActiveRecord::Base
  belongs_to :group
  belongs_to :program

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
