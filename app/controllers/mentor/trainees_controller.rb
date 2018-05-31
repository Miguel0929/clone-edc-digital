class Mentor::TraineesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_mentor
  before_action :set_coach, only: [:destroy]
  add_breadcrumb "EDC DIGITAL", :root_path

  def index
    add_breadcrumb "<a class='active' href='#{ mentor_trainees_path }'>Aprendices</a>".html_safe
    @coach = current_user
    @trainees = @coach.trainees
    @trainees = @trainees.page(params[:page]).per(10)
    @trainees = @trainees.students_table.where('users.id in (?)', current_user.groups.joins(:active_students).pluck('users.id')).search_query(params[:query]) if params[:query].present?
  end

end
