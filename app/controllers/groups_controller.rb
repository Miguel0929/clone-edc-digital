class GroupsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin
  before_action :set_group, only: [:show, :edit, :update, :destroy]

  add_breadcrumb "EDCDIGITAL", :root_path

  def index
    add_breadcrumb "<a class='active' href='#{groups_path}'>Grupos</a>".html_safe
    @groups = Group.all
  end

  def show
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

    @group = Group.new(group_params)

    if @group.save
      redirect_to groups_path, notice: "Se creo exitosamente el grupo #{@group.name}"
    else
      render :new
    end
  end

  def update
    add_breadcrumb "Grupos", :groups_path
    add_breadcrumb "<a class='active' href='#{edit_group_path(@group)}'>#{@group.name}</a>".html_safe

    before_update_ids = @group.programs.pluck(:id)
    if @group.update(group_params)
      NewProgramNotificationJob.perform_async(before_update_ids, @group.programs.pluck(:id))
      redirect_to groups_path, notice: "Se actualizó exitosamente el grupo #{@group.name}"
    else
      render :edit
    end
  end

  def destroy
    @group.destroy
    redirect_to groups_path, notice: "Se eliminó el grupo #{@group.name}"
  end

  private
  def set_group
    @group = Group.find(params[:id])
  end

  def group_params
    params.require(:group).permit(:name, :key, :state_id, :university, :category, program_ids: [], user_ids: [])
  end
end
