class Search::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin_or_mentor

  add_breadcrumb "EDC DIGITAL", :root_path

  def index
    add_breadcrumb "<a class='active' href='#{search_users_path}'>Buscar</a>".html_safe

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
