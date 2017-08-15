class ProgramActivesController < ApplicationController
	before_action :authenticate_user!

  def post
  	aux=ProgramActive.where(user_id: params[:user], program_id: params[:program]).first
  	if aux.nil?
  		aux = ProgramActive.create(user_id: params[:user], program_id: params[:program], status: true)
  	else
  		aux.update(status: !aux.status)
  	end	
  	render :json => {"program_active"=>aux}
  end
  	
end
