module ActiveElementsHelper


  def get_active_elements(current_user, class_name)
    ######## Elegir cuál de las clases que le pertenecen a programas se buscará ###
      case class_name
      when "quizzes"
        requested_class = Quiz
      when "template_refilables"
        requested_class = TemplateRefilable
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
        if current_user.percentage_questions_answered_for(anterior) >= 1 || c == 1 || (current_user.percentage_content_visited_for(anterior) >= 1 && anterior.questions? == false)
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
        if current_user.percentage_questions_answered_for(anterior) >= 1 || c == 1 || (current_user.percentage_content_visited_for(anterior) >= 1 && anterior.questions? == false)
          ids.push(p.id)
        else
          break
        end
      end
      programs_moral = LearningPathContent.where(id: ids)
    end
    ######## Llamar a los programas pertenecientes a esos learning paths #############
    lp_contents_f = programs_fisica.nil? ? [] : (programs_fisica).sort_by &:position
    lp_contents_m = programs_moral.nil? ? [] : (programs_moral).sort_by &:position
    active_elements = []
    lp_contents_f.each do |lp|
      requested_class.where(program_id: Program.find(lp.content_id).id).each do |element| active_elements << element end
    end
    lp_contents_m.each do |lp|
      requested_class.where(program_id: Program.find(lp.content_id).id).each do |element| active_elements << element end
    end
    if !current_user.group.nil?
      current_user.group.programs.each do |pg|
        if !ProgramActive.where(user: current_user, program_id: pg).first.nil? && ProgramActive.where(user: current_user, program_id: pg).first.status
          requested_class.where(program_id: pg.id).each do |element| active_elements << element end
        end
      end
    end
    ########################################################################## 
    return active_elements  
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
        if current_user.percentage_questions_answered_for(anterior) >= 1 || c == 1 || (current_user.percentage_content_visited_for(anterior) >= 1 && anterior.questions? == false)
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
        if current_user.percentage_questions_answered_for(anterior) >= 1 || c == 1 || (current_user.percentage_content_visited_for(anterior) >= 1 && anterior.questions? == false)
          ids.push(p.id)
        else
          break
        end
      end
      programs_moral = LearningPathContent.where(id: ids)
    end
    ######## Llamar a los programas pertenecientes a esos learning paths #############
    lp_contents_f = programs_fisica.nil? ? [] : (programs_fisica).sort_by &:position
    lp_contents_m = programs_moral.nil? ? [] : (programs_moral).sort_by &:position
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
    ########################################################################## 
    return active_programs 
  end


end
