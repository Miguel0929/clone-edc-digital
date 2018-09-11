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
    if Program.count == 0 then return Program.all end
    if group.program_sequence.nil? then set_program_order(group) end
    order = group.program_sequence.sequence
    return programs.sort_by do |program| order.index(program[:id]) end 
  end

  def sort_template_refilables(group)
    templates_arry = []
    physical = group.learning_path.learning_path_contents.where(content_type: "TemplateRefilable").order(:position) rescue nil
    moral = group.learning_path2.learning_path_contents.where(content_type: "TemplateRefilable").order(:position) rescue nil
    physical.each do |ph|
      templates_arry << TemplateRefilable.find(ph.content_id) unless TemplateRefilable.find(ph.content_id).nil? 
    end unless physical.nil?
    moral.each do |mo|
      templates_arry << TemplateRefilable.find(mo.content_id) unless TemplateRefilable.find(mo.content_id).nil? 
    end unless moral.nil?
    group.template_refilables.each do |temp|
      templates_arry << temp
    end
    return templates_arry.uniq
  end

  def sort_quizzes(group)
    quizzes = []
    physical = group.learning_path.learning_path_contents.where(content_type: "Quiz").order(:position) rescue nil
    moral = group.learning_path2.learning_path_contents.where(content_type: "Quiz").order(:position) rescue nil
    physical.each do |ph|
      quizzes << Quiz.find(ph.content_id) unless Quiz.find(ph.content_id).nil? 
    end unless physical.nil?
    moral.each do |mo|
      quizzes << Quiz.find(mo.content_id) unless Quiz.find(mo.content_id).nil? 
    end unless moral.nil?
    group.quizzes.each do |quiz|
      quizzes << quiz
    end
    return quizzes.uniq
  end

  def sort_delireverables(group)
    delireverables = []
    physical = group.learning_path.learning_path_contents.where(content_type: "DelireverablePackage").order(:position) rescue nil
    moral = group.learning_path2.learning_path_contents.where(content_type: "DelireverablePackage").order(:position) rescue nil
    physical.each do |ph|
      delireverables << DelireverablePackage.find(ph.content_id) unless DelireverablePackage.find(ph.content_id).nil? 
    end unless physical.nil?
    moral.each do |mo|
      delireverables << DelireverablePackage.find(mo.content_id) unless DelireverablePackage.find(mo.content_id).nil? 
    end unless moral.nil?
    group.delireverable_packages.each do |del|
      delireverables << del
    end
    return delireverables.uniq
  end

  def user_program_quizzes_count(user, quizzes)
    total = 0 
    quizzes.each do |quiz|
      if quiz.answered(user) > 0
        total += 1
      end  
    end
    total  
  end
  def user_program_quizzes_avg(user, quizzes)
    total = 0; promedios = 0 
    quizzes.each do |quiz|
      p promedios += quiz.promedio(user)
      p total += 1
    end
    promedios/total rescue 0 
  end
  def user_program_refilables_count(user, template_refilables)
    total = 0
    template_refilables.each do |refil|
      rubricas = refil.evaluation_refilables.pluck(:id)
      revisiones = UserEvaluationRefilable.where(evaluation_refilable_id: rubricas, user_id: user.id).count
      if rubricas.length == revisiones && rubricas.length > 0
        total+=1
      end  
    end 
    total 
  end
  def user_program_refilables_avg(user, template_refilables)
    total = 0
    template_refilables.each do |refil|
      rubricas = refil.evaluation_refilables.pluck(:id)
      revisiones = UserEvaluationRefilable.where(evaluation_refilable_id: rubricas, user_id: user.id).count
      if rubricas.length == revisiones && rubricas.length > 0
        total+=1
      end  
    end 
    total 
  end    
end
