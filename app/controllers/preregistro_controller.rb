class PreregistroController < ApplicationController
  before_action :set_user, only: [:link_activation]

  def index
    render layout: "layouts/preregistro"
  end 
  
  def verificar
    @user=User.find_by(email: invitacion_params[:email])
    if @user.nil?
    	@email = invitacion_params[:email]
    end	
    render layout: "layouts/preregistro"
  end

  def reenviar
    @user = User.find(params[:id])
    PreregistroJob.perform_async(@user.email,"reenviar")
    flash[:notice] = "Se ha enviado una invitación al correo #{@user.email}"
    redirect_to new_user_session_path
  end

  def activation_code
  	code = UserCode.find_by(codigo: user_code_params[:code])
    if code.nil?
      redirect_to :back ,alert: "Código de activación incorrecto" 
    else
      if user_code_params[:mail]==code.user.email && user_code_params[:code]==code.codigo
        @user=User.invite!(:email => user_code_params[:mail]) do |u|
          u.skip_invitation = true
        end  
        render layout: "layouts/preregistro"
      else
        redirect_to :back ,alert: "Código de activación incorrecto." 
      end  
    end  
  end  

  def redireccionar
    redirect_to preregistro_index_path
  end  

  private
  def invitacion_params
    attributes = {email: params[:email]}
  end
  def user_code_params
    attributes = {mail: params[:mail], code: params[:code]}
  end
  def set_user

  end  

end
