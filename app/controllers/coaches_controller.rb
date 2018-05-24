class TraineesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_mentor
  before_action :set_coach, only: [:destroy]
  add_breadcrumb "EDC DIGITAL", :root_path

  def index
    add_breadcrumb "<a class='active' href='#{ coaches_path }'>Tutores</a>".html_safe
    @coaches = User.where(id: User.all.pluck(:coach_id).uniq)
    @coaches = @coaches.where("email = ? OR first_name = ? OR last_name = ?", params[:query], params[:query], params[:query]) if params[:query].present?
    #@trainees = @coach.trainees
    #@trainees = @trainees.page(params[:page]).per(10)
    #@trainees = @trainees.students_table.where('users.id in (?)', current_user.groups.joins(:active_students).pluck('users.id')).search_query(params[:query]) if params[:query].present?
  end

  def new
    add_breadcrumb "<a href='#{ coaches_path }'>Aprendices</a>".html_safe
    add_breadcrumb "<a class='active' href='#{ new_mentor_trainee_path }'>Nuevos aprendices</a>".html_safe
  end

  def create

  end

  def batch_deletion
    
  end

  def destroy

  end  

  private
  def set_coach
    @coach = User.find(params[:id])
  end
end
