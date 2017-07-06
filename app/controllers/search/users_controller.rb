class Search::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin_or_mentor

  def index
    @users = case current_user.role
      when 'admin'
        User.search(params[:search])
        .records
        .where(role: %w{1 0})
      when 'mentor'
        User.search(params[:search])
        .records
        .where(role: %w{0})
      end
  end
end
