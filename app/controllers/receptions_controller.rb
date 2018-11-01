class ReceptionsController < ApplicationController
	before_action :authenticate_user!, only: [:create, :destroy, :update, :index]
	before_action :require_admin, only: [:create, :destroy, :update, :index]
	before_action :set_reception, only: [:show]	
	before_action :set_reception_id, only: [:destroy, :update]	
	include MailTemplateHelper

	def index
		add_breadcrumb (ENV['COMPANY_NAME'].nil? ? "Inicio" : ENV['COMPANY_NAME']), :root_path
		add_breadcrumb "<a class='active' href='#{receptions_path}'>Recepción</a>".html_safe
		@receptions = Reception.all
		@reception = Reception.new
	end	
	
	def show
		@user = User.new
		@group = @reception.group
		render layout: "layouts/preregistro"
	end

	def create
		@reception = Reception.new(reception_params)
		group = Group.create(name: "#{reception_params[:name]}-reception", key: "rec-#{reception_params[:name]}")
		@reception.group_id = group.id
		if @reception.save
	    redirect_to receptions_path, notice: "Se creó exitosamente la landing #{@reception.name}, y el grupo de recepión #{@reception.group.name}"
	  else
	    render :index
	  end
	end

	def update
		if @reception.update(name: params[:e_name])
			redirect_to receptions_path, notice: "Se actualizó exitosamente la landing #{@reception.name}"
		else
			render :index
		end
	end	

	def destroy
		@reception.destroy
		redirect_to receptions_path, notice: "Se eliminó exitosamente la landing #{@reception.name}"
	end

	def register
		@user = User.unscoped.find_by(email: user_params[:email])
		@group = Group.find(user_params[:group_id])
		if @user.nil?
			@user = User.invite!(:email => user_params[:email], :first_name => user_params[:first_name], :group_id => user_params[:group_id], :last_name => user_params[:last_name], :phone_number => user_params[:phone_number]) do |u|
        u.skip_invitation = true
      end
      send_mail(@user, accept_user_invitation_url)
      flash[:notice] = "El correo electronico #{@user.email} ha sido registrado, verifica tu email para completar el registro"
		elsif !@user.nil? && !@user.invitation_token.nil?
			@user.update(email: user_params[:email], first_name: user_params[:first_name], group_id: user_params[:group_id], :last_name => user_params[:last_name], :phone_number => user_params[:phone_number])
      @user.invite! do |u|
        u.skip_invitation = true
      end
      send_mail(@user, accept_user_invitation_url)
      flash[:notice] = "El correo electronico #{@user.email} ha sido registrado, verifica tu email para completar el registro"
    elsif !@user.nil? && @user.invitation_token.nil?
      flash[:notice] = "El correo electronico #{@user.email} ya está asociado a una cuenta activa"
		end
		
		redirect_to	reception_path(@group.reception.name)
	end	

	private
	def set_reception
		@reception = Reception.find_by(name: params[:id])
	end
	def set_reception_id
		@reception = Reception.find(params[:id])
	end

	def reception_params
	   params.require(:reception).permit(:name)
	end	

	def user_params
		params.require(:user).permit(:first_name, :last_name, :phone_number, :email, :group_id, :password, :password_confirmation)
	end

    def send_mail(user, url)

      invitation_link = url + "?invitation_token=" + user.raw_invitation_token

      template_title = "¡Es tiempo de iniciar!"
      template_name = "Hola"
      template_message = "Te informamos que tu cuenta en " + company_name_helper('nuestra plataforma') + " ha sido creada. Para comenzar, debes activar tu cuenta dando clic en el siguiente botón: </p> <table width='100%' cellspacing='0' cellpadding='0' border='0'><tbody><tr><td style='padding: 10px 10px 10px 10px' bgcolor: '#f8f8f8' align: 'center'><table cellspacing='0' cellpadding='0' border='0'><tbody><tr><td><a href='" + invitation_link + "' class='button'>ACTIVA TU CUENTA AQUÍ</a></td></tr></tbody></table></td></tr></tbody></table></br><p style='margin-top: 20px;'>En caso de que no logres acceder, puedes copiar la siguiente liga y pegarla en una ventana de tu navegador:</p><a href='" + invitation_link + "' >" + invitation_link + "</a></br></br><p style='margin-top: 20px;'>Si tienes alguna duda o comentario, no dudes en escribirnos a <strong>" + mailer_from_helper('') + "</strong>. Nuestro equipo de atención a clientes enseguida te antenderá."
      template_footer = "¡Bienvenido!"
      mail_recipient = user.email
      mail_subject = "Tu cuenta en " + company_name_helper('nuestra plataforma') + " ha sido creada"

      send_mail_template(template_title, template_name, template_message, template_footer, mail_recipient, mail_subject)

    end

end
