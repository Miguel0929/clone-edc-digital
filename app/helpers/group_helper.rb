module GroupHelper

  def learning_path_content_type(type)
    case type
    when "Program"
      return "Programa"
    when "Quiz"
      return "Examen"
    when "TemplateRefilable"
     return "Rellenable"
    when "DelireverablePackage"
      return "Entregable"
    else
      return "N/A"  
    end
  end

  def set_program_order(group)
    sequence = []
    # Obtener contenidos tipo 'Programa' 
    physical = group.learning_path.learning_path_contents.where(content_type: "Program").order(:position) rescue nil
    moral = group.learning_path2.learning_path_contents.where(content_type: "Program").order(:position) rescue nil
    # Agregar programas de ruta física
    physical.each do |ph|
      sequence << Program.find(ph.content_id).id unless Program.find(ph.content_id).nil? 
    end unless physical.nil?
    # Agregar programas de ruta moral
    moral.each do |mo|
      sequence << Program.find(mo.content_id).id unless Program.find(mo.content_id).nil? 
    end unless moral.nil?
    # Agregar programas de grupo
    group.programs.each do |pg|
      sequence << pg.id
    end
    # Crear / actualizar group.program_sequence
    sequence = sequence.uniq
    if group.program_sequence.nil?
      ProgramSequence.create(group_id: group.id, sequence: sequence)
    else 
      group.program_sequence.update(group_id: group.id, sequence: sequence)
    end
  end

  def sort_programs(group, programs)
    if group.program_sequence.nil? then set_program_order(group) end
    order = group.program_sequence.sequence
    return programs.sort_by do |program| order.index(program[:id]) end 
  end

end
