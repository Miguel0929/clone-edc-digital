class Mentors::StudentsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_mentor

  def index
    @users = User.students_table.where('users.id in (?)', current_user.groups.joins(:active_students).pluck('users.id'))
  end
end
