class GroupsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin
  before_action :set_group, only: [:show, :edit, :update, :destroy, :sort_route, :sort, :student_control, :reassign_student, :unlink_student, :notification_route, :no_group_students, :clone, :codes]

  add_breadcrumb "EDCDIGITAL", :root_path

  def index
    add_breadcrumb "<a class='active' href='#{groups_path}'>Grupos</a>".html_safe
    @groups = Group.all
  end

  def show
    @students = @group.active_students.page(params[:page]).per(50)
    @students = @group.student_search(params[:query]).page(params[:page]).per(50) if params[:query].present?
    add_breadcrumb "Grupos", :groups_path
    add_breadcrumb "<a class='active' href='#{group_path(@group)}'>#{@group.name}</a>".html_safe
  end

  def codes
  end  

  def new
    add_breadcrumb "Grupos", :groups_path
    add_breadcrumb "<a class='active' href='#{new_group_path}'>Crear grupo</a>".html_safe

    @group = Group.new
    @programs = Program.all
    @quizzes = Quiz.all
    @refilables = TemplateRefilable.all
    @delireverables = DelireverablePackage.all
  end

  def edit
    add_breadcrumb "Grupos", :groups_path
    add_breadcrumb "<a class='active' href='#{edit_group_path(@group)}'>#{@group.name}</a>".html_safe
    @contents_fisica_programs = []; @contents_fisica_quizzes = []; @contents_fisica_refilables = []; @contents_fisica_delireverables = []
    @contents_moral_programs = []; @contents_moral_quizzes = []; @contents_moral_refilables = []; @contents_moral_delireverables = []
    (@group.learning_path.nil?) ?  @contents_fisica = [] : @contents_fisica = @group.learning_path.learning_path_contents
    (@group.learning_path2.nil?) ?  @contents_moral = [] : @contents_moral = @group.learning_path2.learning_path_contents
    @contents_fisica.each do |c| 
      if c.content_type == "Program"
        @contents_fisica_programs << c
      elsif c.content_type == "Quiz"
        @contents_fisica_quizzes << c
      elsif c.content_type == "TemplateRefilable"  
        @contents_fisica_refilables << c
      elsif c.content_type == "DelireverablePackage"  
        @contents_fisica_delireverables << c 
      end  
    end
    @contents_moral.each do |c| 
      if c.content_type == "Program"
        @contents_moral_programs << c
      elsif c.content_type == "Quiz"
        @contents_moral_quizzes << c
      elsif c.content_type == "TemplateRefilable"  
        @contents_moral_refilables << c
      elsif c.content_type == "DelireverablePackage"  
        @contents_moral_delireverables << c 
      end  
    end
    #render :json => {1=> }  
    lp_fisica = @group.learning_path
    if lp_fisica.nil?
      lpf_programs = []; lpf_quizzes = []; lpf_refilables = []; lpf_delireverables = []
    else  
      lpf_programs = lp_fisica.learning_path_contents.where(content_type: "Program").pluck(:content_id)
      lpf_quizzes = lp_fisica.learning_path_contents.where(content_type: "Quiz").pluck(:content_id)
      lpf_refilables = lp_fisica.learning_path_contents.where(content_type: "TemplateRefilable").pluck(:content_id)
      lpf_delireverables = lp_fisica.learning_path_contents.where(content_type: "DelireverablePackage").pluck(:content_id)
    end

    lp_moral = @group.learning_path2
    if lp_moral.nil?
      lpm_programs = []; lpm_quizzes = []; lpm_refilables = []; lpm_delireverables = [] 
    else  
      lpm_programs = lp_moral.learning_path_contents.where(content_type: "Program").pluck(:content_id)
      lpm_quizzes = lp_moral.learning_path_contents.where(content_type: "Quiz").pluck(:content_id)
      lpm_refilables = lp_moral.learning_path_contents.where(content_type: "TemplateRefilable").pluck(:content_id)
      lpm_delireverables = lp_moral.learning_path_contents.where(content_type: "DelireverablePackage").pluck(:content_id)
    end

    @programs = Program.where.not(id: lpf_programs + lpm_programs)
    @quizzes = Quiz.where.not(id: lpf_quizzes + lpm_quizzes)
    @refilables = TemplateRefilable.where.not(id: lpf_refilables + lpm_refilables)
    @delireverables = DelireverablePackage.where.not(id: lpf_delireverables + lpm_delireverables)
  end

  def create
    add_breadcrumb "Grupos", :groups_path
    add_breadcrumb "<a class='active' href='#{new_group_path}'>Crear grupo</a>".html_safe

    @group = Group.new(name: group_params[:name], key: group_params[:key], state_id: group_params[:state_id], university_id: group_params[:university_id], category: group_params[:category], learning_path_id: group_params[:learning_path_id], learning_path2_id: group_params[:learning_path2_id])
    if @group.save
      @group.users << User.where(id: group_params[:user_ids].delete_if {|x| x == "" } )
      @group.students << User.where(id: group_params[:student_ids].delete_if {|x| x == "" } )
      @group.programs << Program.where(id: group_params[:program_ids].delete_if {|x| x == "" } )
      @group.quizzes << Quiz.where(id: group_params[:quiz_ids].delete_if {|x| x == "" } )
      @group.delireverable_packages << DelireverablePackage.where(id: group_params[:delireverable_package_ids].delete_if {|x| x == "" } )
      @group.template_refilables << TemplateRefilable.where(id: group_params[:template_refilable_ids].delete_if {|x| x == "" } )
      redirect_to group_path(@group.id), notice: "Se creo exitosamente el grupo #{@group.name}, ahora ordena la \"Ruta de aprendizaje\""
    else
      render :new
    end
  end

  def update
    add_breadcrumb "Grupos", :groups_path
    add_breadcrumb "<a class='active' href='#{edit_group_path(@group)}'>#{@group.name}</a>".html_safe
    source = URI(request.referer).path

    before_update_ids = @group.programs.pluck(:id)
    if @group.update(group_params)
      NewProgramNotificationJob.perform_async(before_update_ids, @group.programs.pluck(:id))
      if source == '/groups/' + @group.id.to_s + '/student_control'
        redirect_to student_control_group_path(@group), notice: "Vinculación  de alumnos actualizada"
      else
        redirect_to edit_group_path, notice: "Se actualizó exitosamente el grupo #{@group.name}"
        #groups_path
      end
    else
      render :edit
    end
  end

  def destroy
    if !@group.active_students.empty?
      redirect_to reassign_student_group_path(@group), alert: "El grupo debe estar vacío antes de eliminarlo, desvincula a todos sus estudiantes aquí"
    else
      groupstat = GroupStat.find_by(group_id: @group.id)
      if !groupstat.nil? then groupstat.destroy end
      @group.destroy
      redirect_to groups_path, notice: "Se eliminó el grupo #{@group.name}"
    end
  end

  def sort_route
    add_breadcrumb "Grupos", :groups_path
    add_breadcrumb "<a class='active' href='#{sort_route_group_path(@group)}'>#{@group.name} - Ruta de aprendizaje</a>".html_safe
    ids=@group.programs.ruta.map{|p|p.id}
    @programs=@group.group_programs.where(program_id: ids).order(:position)
  end

  def sort
    p @group
    params[:program].each_with_index do |id, index|
      @group.group_programs.where(program_id: id).first.update_attributes({position: index + 1})
    end
    render nothing: true
  end

  def bloquear
    group = Group.find(params[:id])
    if group.financiero.nil?
      group.update(financiero: false)
    else
      group.update(financiero: !group.financiero)
    end 
    render :json => {status: group} 
  end   

  def notification_route
    LearningPathNotificationJob.perform_async(@group,dashboard_learning_path_url)
    redirect_to sort_route_group_path, notice: "Notificaciones enviadas al grupo #{@group.name}"
  end

  def student_control
    add_breadcrumb "Grupos", :groups_path
    add_breadcrumb "<a class='active' href='#{student_control_group_path(@group)}'>#{@group.name}</a>".html_safe
    @groups = Group.all
    @students_no_group = User.students.includes(:group).where(groups: {id: nil})
  end

  def reassign_student
    @groups = Group.all
    @source = URI(request.referer || "").path
    if @source == '/groups/' + params[:id] + '/student_control'
      @return_url = student_control_group_path(@group)
    else
      @return_url = groups_path
    end
    add_breadcrumb "Grupos", :groups_path
    add_breadcrumb "<a class='active' href='#{reassign_student_group_path(@group)}'> Reasignar estudiantes de grupo: #{@group.name}</a>".html_safe
  end

  def unlink_student
    users = params[:users_ids]
    if !users.nil?
      users.each do |user|
        thisuser = User.find(user)
        thisuser.update(group_id: nil)
      end
    end

    redirect_to student_control_group_path(@group), notice: "Desvinculación exitosa, recuerda reasignar a los alumnos eliminados a otro grupo"
  end

  def no_group_students
    selected_group = Group.find_by(id: params[:group_id])
    old_students = selected_group.students.pluck(:id)
    new_students = []
    params[:student_ids].map{ |new| new_students.push(new.to_i)}
    all_students = old_students + new_students
    all_students.delete(0)
    if selected_group.update(student_ids: all_students)
      redirect_to student_control_group_path(@group), notice: "Los alumnos han sido asignados a #{selected_group.name}"
    end
  end

  def change_group
    source = params[:source]
    host_group = Group.find(params[:host_group])
    old_students = host_group.students.pluck(:id)
    reassigned_students = params[:student_ids].map{ |num| num.to_i}
    reassigned_students.delete(0)
    all_students = old_students + reassigned_students
    if host_group.update(student_ids: all_students)
      if source == '/groups/' + params[:id] + '/student_control'
        redirect_to student_control_group_path(params[:id]), notice: "Los alumnos fueron reasignados exitosamente a #{host_group.name}"
      else
        redirect_to groups_path, notice: "Los alumnos fueron reasignados exitosamente a #{host_group.name}"
      end
    end
  end

  def clone
    attributes = @group.attributes
    attributes.delete('id')
    attributes.delete('created_at')
    attributes.delete('updated_at')

    group = Group.new(attributes)
    
    @group.programs.order(:position).each do |program|
      group.programs << program
    end

    group.quizzes = @group.quizzes
    group.users = @group.users
    group.key = "COPIA-#{@group.key}"

    group.save({ validate: false })

    redirect_to groups_path, notice: 'Grupo clonado exitosamente'
  end

  private
  def set_group
    @group = Group.find(params[:id])
  end

  def group_params
    params.require(:group).permit(:name, :key, :state_id, :university_id, :category, :learning_path_id, :learning_path2_id, program_ids: [], user_ids: [], student_ids: [], quiz_ids: [], delireverable_package_ids: [], template_refilable_ids: [])
  end
end
