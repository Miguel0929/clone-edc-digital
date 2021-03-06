class Dashboard::UsersController < ApplicationController
  before_action :authenticate_user!
  add_breadcrumb (ENV['COMPANY_NAME'].nil? ? "Inicio" : ENV['COMPANY_NAME']), :root_path

  def show
    @user = current_user

    ids_comp = []; ids_fisica = []; ids_moral = [] 

    current_user.group.nil? || current_user.group.learning_path.nil? ? program_fisico = [] : program_fisico = current_user.group.learning_path.learning_path_contents.where(content_type: "Program").order(:position)
    c=0
    program_fisico.each do |p|
      #c+=1
      #anterior = p.anterior(current_user.group.learning_path)
      #if c==1 || current_user.percentage_questions_answered_for(anterior) >= 95 || (current_user.percentage_content_visited_for(anterior) == 100 && anterior.questions? == false)
        ids_fisica << p.content_id
      #else
      #  break
      #end
    end

    current_user.group.nil? || current_user.group.learning_path2.nil? ? program_moral = [] : program_moral = current_user.group.learning_path2.learning_path_contents.where(content_type: "Program").order(:position)
    c=0
    program_moral.each do |p|
      #c+=1
      #anterior = p.anterior(current_user.group.learning_path2)
      #if c==1 || current_user.percentage_questions_answered_for(anterior) >= 95 || (current_user.percentage_content_visited_for(anterior) == 100 && anterior.questions? == false)
        ids_moral << p.content_id
      #else
      #  break
      #end
    end

    current_user.group.nil? || current_user.group.programs.nil? ? program_group = [] : program_group = current_user.group.programs.map{|p|p.id}
    if program_fisico == [] && program_moral == []
      p_f = []; p_m = []; 
    elsif program_moral == [] && program_fisico != [] 
      p_f = program_fisico.pluck(:content_id); p_m = []; 
    elsif program_fisico == [] && program_moral != []
      p_f = []; p_m = program_moral.pluck(:content_id);
    elsif !program_fisico.nil? && !program_moral.nil?
      p_f = program_fisico.pluck(:content_id); p_m = program_moral.pluck(:content_id);  
    end 
    complementarios = program_group - (p_f + p_m)

    complementarios.each do |id|
      if !ProgramActive.where(user: current_user, program_id: id).first.nil? && ProgramActive.where(user: current_user, program_id: id).first.status
        ids_comp << id
      end
    end

    @programs=Program.where(id: ids_comp+ids_fisica+ids_moral)
    
    add_breadcrumb "<a class='active' href='#{dashboard_user_path(@user)}'>Informaci??n de perfil</a>".html_safe
  end

  def change_tour_trigger
    puts current_user.tour_trigger
  	position = params[:position].to_i
  	trigger = current_user.tour_trigger
  	if position == 1
  		upgrade = {:first => false, :second => trigger[:second], :third => trigger[:third], :fourth => trigger[:fourth], :fifth => trigger[:fifth]}
  	elsif position == 2
  		upgrade = {:first => trigger[:first], :second => false, :third => trigger[:third], :fourth => trigger[:fourth], :fifth => trigger[:fifth]}
  	elsif position == 3
  		upgrade = {:first => trigger[:first], :second => trigger[:second], :third => false, :fourth => trigger[:fourth], :fifth => trigger[:fifth]}
  	elsif position == 4
  		upgrade = {:first => trigger[:first], :second => trigger[:second], :third => trigger[:third], :fourth => false, :fifth => trigger[:fifth]}
  	else
  		upgrade = {:first => trigger[:first], :second => trigger[:second], :third => trigger[:third], :fourth => trigger[:fourth], :fifth => false}
  	end

  	event = current_user.update(tour_trigger: upgrade)
  	if event
  		render json: { message: event }, status: :ok
  	else
  		render json: { errors: event.errors.full_messages }, status: 422
  	end
  end
end
