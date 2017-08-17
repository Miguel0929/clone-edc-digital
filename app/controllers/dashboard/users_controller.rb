class Dashboard::UsersController < ApplicationController
  before_action :authenticate_user!

  add_breadcrumb "EDCDIGITAL", :root_path

  def show
    @user = User.find(params[:id])
    add_breadcrumb "<a class='active' href='#{dashboard_user_path(@user)}'>Información de perfil</a>".html_safe
  end

  def change_tour_trigger
  	puts "ay wey"
  	position = params[:position].to_i
  	trigger = current_user.tour_trigger
  	if position == 1
  		tested = trigger[:first]
  	end
  	puts tested
  	render json: { message: "changed" }, status: :ok
  end
end
