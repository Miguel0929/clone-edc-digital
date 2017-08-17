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
  		upgrade = {:first => false, :second => trigger[:second], :third => trigger[:third], :fourth => trigger[:fourth], :fifth => trigger[:fifth]}
  	elsif position == 2
  		upgrade = {:first => trigger[:first], :second => false, :third => trigger[:third], :fourth => trigger[:fourth], :fifth => trigger[:fifth]}
  	elsif position == 3
  		upgrade = {:first => trigger[:first], :second => trigger[:second], :third => false, :fourth => trigger[:fourth], :fifth => trigger[:fifth]}
  	elsif position == 4
  		upgrade = {:first => trigger[:first], :second => trigger[:second], :third => trigger[:third], :fourth => false, :fifth => trigger[:fifth]}
  	else
  		upgrade = {:first => trigger[:first], :second => trigger[:second], :third => trigger[:third], :fourth => trigger[:fourth], :fifth => false}
  	end

  	event = current_user.update(tour_trigger: upgrade)
  	puts event
  	if upgrade
  		render json: { message: event }, status: :ok
  	else
  		render json: { errors: event.errors.full_messages }, status: 422
  	end
  end
end
