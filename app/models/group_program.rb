class GroupProgram < ActiveRecord::Base
  belongs_to :group
  belongs_to :program

  def anterior(grupo)
  programas = grupo.group_programs.order(:position)	
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
