class LandingsController < ApplicationController
  layout false
  before_action :redirect_when_is_not_auth

  def index
    render :index
  end

  private
    def redirect_when_is_not_auth
      unless current_user.nil?
        if current_user.admin?
          redirect_to control_panel_index_path
        elsif current_user.mentor?
          redirect_to mentor_groups_path
        elsif current_user.staff?
          redirect_to students_users_path
        elsif current_user.student?
          redirect_to dashboard_learning_path_path
        elsif current_user.profesor?
          #redirect_to profesor_groups_path
          sign_out(current_user)
        end
      end
    end
end