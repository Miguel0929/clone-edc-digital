class GroupsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin
  before_action :set_group, only: [:show, :edit, :update, :destroy, :sort_route, :sort, :student_control, :unlink_student, :notification_route, :no_group_students]

  add_breadcrumb "EDCDIGITAL", :root_path

  def index
    add_breadcrumb "<a class='active' href='#{groups_path}'>Grupos</a>".html_safe
    @groups = Group.all
  end

  def show
    @students = @group.active_students
    @students = @group.student_search(params[:query]) if params[:query].present?
    add_breadcrumb "Grupos", :groups_path
    add_breadcrumb "<a class='active' href='#{group_path(@group)}'>#{@group.name}</a>".html_safe
  end

  def new
    add_breadcrumb "Grupos", :groups_path
    add_breadcrumb "<a class='active' href='#{new_group_path}'>Crear grupo</a>".html_safe

    @group = Group.new
  end

  def edit
    add_breadcrumb "Grupos", :groups_path
    add_breadcrumb "<a class='active' href='#{edit_group_path(@group)}'>#{@group.name}</a>".html_safe
  end

  def create
    add_breadcrumb "Grupos", :groups_path
    add_breadcrumb "<a class='active' href='#{new_group_path}'>Crear grupo</a>".html_safe

    @group = Group.new(name: group_params[:name], key: group_params[:key], state_id: group_params[:state_id], university_id: group_params[:university_id], category: group_params[:category])
    if @group.save
      group_params[:program_ids].each do |p|
        unless p == ""
          m = Program.find(p)
          @group.programs << m
        end
      end
      group_params[:user_ids].each do |u|
        unless u == ""
          m = User.find(u)
          @group.users << m
        end
      end   
      redirect_to sort_route_group_path(@group.id), notice: "Se creo exitosamente el grupo #{@group.name}, ahora ordena la \"Ruta de aprendizaje\""
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
        redirect_to groups_path, notice: "Se actualizó exitosamente el grupo #{@group.name}"
      end
    else
      render :edit
    end
  end

  def destroy
    if !@group.active_students.empty?
      redirect_to groups_path, alert: "El grupo debe estar vacío antes de eliminarlo, desvincula a todos sus estudiantes"
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
    @programs=@group.group_programs.order(:position)
  end

  def sort
    p @group
    params[:program].each_with_index do |id, index|
      @group.group_programs.where(program_id: id).first.update_attributes({position: index + 1})
    end
    render nothing: true
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

  def unlink_student
    users = params[:users_ids]
    if !users.nil?
      users.each do |user|
        thisuser = User.find(user)
        thisuser.update(group_id: nil)
      end
    end

    redirect_to student_control_group_path(@group), notice: "Vinculación  de alumnos actualizada"
    add_breadcrumb "<a class='active' href='#{edit_group_path(@group)}'>#{@group.name}</a>".html_safe
  end

  def unlink_student
    users = params[:users_ids]
    if !users.nil?
      users.each do |user|
        thisuser = User.find(user)
        thisuser.update(group_id: nil)
      end
    end

    redirect_to student_control_group_path(@group), notice: "Vinculación  de alumnos actualizada"
  end

  def no_group_students
    selected_group = Group.find_by(id: params[:group_id])
    old_students = selected_group.students.pluck(:id)
    new_students = []
    params[:student_ids].map{ |new| new_students.push(new.to_i)}
    all_students = old_students + new_students
    all_students.delete(0)
    selected_group.update(student_ids: all_students)
    redirect_to student_control_group_path(@group), notice: "Los estudiantes han sido asignados a #{selected_group.name}"
  end

  private
  def set_group
    @group = Group.find(params[:id])
  end

  def group_params
    params.require(:group).permit(:name, :key, :state_id, :university_id, :category, program_ids: [], user_ids: [], student_ids: [], quiz_ids: [])
  end
end
