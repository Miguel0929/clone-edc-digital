module ActiveElementsHelper


  def get_active_elements(current_user, class_name)
    ######## Elegir cuál de las clases que le pertenecen a programas se buscará ###
      complementarios = []
      case class_name
      when "quizzes"
        requested_class = Quiz
        current_user.group.quizzes.each{|quiz| complementarios << quiz}
      when "template_refilables"
        requested_class = TemplateRefilable
        current_user.group.template_refilables.each{|refil| complementarios << refil }
      end
    ######## Obtener learning path contents en orden de acuerdo a las rutas #######
    programs_fisica = current_user.group.learning_path.learning_path_contents.where(content_type: "Program").order(:position) rescue nil
    c = 0
    c1 = 0
    ids = []
    unless programs_fisica.nil?
      programs_fisica.each do |p|
        c+=1
        anterior = p.anterior(current_user.group.learning_path)
        if current_user.percentage_questions_answered_for(anterior) >= 1 || c == 1 || (current_user.percentage_content_visited_for(anterior) >= 60 && anterior.questions? == false)
          ids.push(p.id)
        else
          break
        end
      end
      programs_fisica = LearningPathContent.where(id: ids)
    end

    programs_moral = current_user.group.learning_path2.learning_path_contents.where(content_type: "Program").order(:position) rescue nil
    c = 0
    c2 = 0
    ids = []
    unless programs_moral.nil?
      programs_moral.each do |p|
        c+=1
        anterior = p.anterior(current_user.group.learning_path2)
        if current_user.percentage_questions_answered_for(anterior) >= 1 || c == 1 || (current_user.percentage_content_visited_for(anterior) >= 60 && anterior.questions? == false)
          ids.push(p.id)
        else
          break
        end
      end
      programs_moral = LearningPathContent.where(id: ids)
    end
    ######## Llamar a los programas pertenecientes a esos learning paths #############
    if programs_fisica.nil?
      lp_contents_f = []
    else
      lp_contents_f = (programs_fisica).sort_by &:position
    end
    if programs_moral.nil?
      lp_contents_m = []
    else
      lp_contents_m = (programs_moral).sort_by &:position
    end

    active_elements = complementarios

    lp_contents_f.each do |lp|
      requested_class.where(program_id: lp.content_id).each do |element| active_elements << element end
    end
    lp_contents_m.each do |lp|
      requested_class.where(program_id: lp.content_id).each do |element| active_elements << element end
    end
    if !current_user.group.nil?
      current_user.group.programs.each do |pg|
        if !ProgramActive.where(user: current_user, program_id: pg).first.nil? && ProgramActive.where(user: current_user, program_id: pg).first.status
          requested_class.where(program_id: pg.id).each do |element| active_elements << element end
        end
      end
    end
    ########################################################################## 
    return active_elements.uniq

  end


  def get_active_programs(current_user)
    ######## Obtener learning path contents en orden de acuerdo a las rutas #######
    programs_fisica = current_user.group.learning_path.learning_path_contents.where(content_type: "Program").order(:position) rescue nil
    c = 0
    c1 = 0
    ids=[]
    unless programs_fisica.nil?
      programs_fisica.each do |p|
        c+=1
        anterior = p.anterior(current_user.group.learning_path)
        if current_user.percentage_questions_answered_for(anterior) >= 1 || c == 1 || (current_user.percentage_content_visited_for(anterior) >= 60 && anterior.questions? == false)
          ids.push(p.id)
        else
          break
        end
      end
      programs_fisica = LearningPathContent.where(id: ids)
    end

    programs_moral = current_user.group.learning_path2.learning_path_contents.where(content_type: "Program").order(:position) rescue nil
    c = 0
    c2 = 0
    ids = []
    unless programs_moral.nil?
      programs_moral.each do |p|
        c+=1
        anterior = p.anterior(current_user.group.learning_path2)
        if current_user.percentage_questions_answered_for(anterior) >= 1 || c == 1 || (current_user.percentage_content_visited_for(anterior) >= 60 && anterior.questions? == false)
          ids.push(p.id)
        else
          break
        end
      end
      programs_moral = LearningPathContent.where(id: ids)
    end
    ######## Llamar a los programas pertenecientes a esos learning paths #############
    if programs_fisica.nil?
      lp_contents_f = []
    else
      lp_contents_f = (programs_fisica).sort_by &:position
    end
    if programs_moral.nil?
      lp_contents_m = []
    else
      lp_contents_m = (programs_moral).sort_by &:position
    end
    active_programs = []
    lp_contents_f.each do |lp|
      active_programs << Program.find(lp.content_id)
    end
    lp_contents_m.each do |lp|
      active_programs << Program.find(lp.content_id)
    end
    if !current_user.group.nil?
      current_user.group.programs.each do |pg|
        if !ProgramActive.where(user: current_user, program_id: pg).first.nil? && ProgramActive.where(user: current_user, program_id: pg).first.status
          active_programs << pg
        end
      end
    end
    ######## Usar uniq en los programas para que no se repitan ###############
    active_programs = active_programs.uniq
    ########################################################################## 
    return active_programs 
  end

  def clean_repeated_refilables(program, user)
    # Todos los refilables (o respuestas) de este usuario y de este programa
    refiles = Refilable.where(template_refilable_id: TemplateRefilable.where(program_id: program).pluck(:id), user_id: user)
    # Revisar si hay más de un refilable por template refilable (no debería porque solo se editan, no se crean nuevos)
    if refiles.pluck(:template_refilable_id).length != refiles.pluck(:template_refilable_id).uniq.length
      # Seleccionar el template_refilable_id de los refilables que están repetidos (más de 1 refilable por template_refilable_id)
      refiles.select([:template_refilable_id]).group(:template_refilable_id).having("count(template_refilable_id) > 1").each do |rep|
        # Seleccionar aquellos refiles de template_refilable_id repetidos
        refils_rep = refiles.where(template_refilable_id: rep.template_refilable_id)
        # Eliminar todos los duplicados menos el último o el más reciente
        refils_rep.order(:created_at)[0..(refils_rep.length - 2)].map{|r| r.destroy}
      end
    end
  end
end
