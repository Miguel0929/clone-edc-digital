class ReceptionsController < ApplicationController
	before_action :authenticate_user!, only: [:create, :destroy, :update, :index]
	before_action :require_admin, only: [:create, :destroy, :update, :index]
	before_action :set_reception, only: [:show]	
	before_action :set_reception_id, only: [:destroy, :update]	
	def index
		add_breadcrumb "EDC DIGITAL", :root_path
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
		redirect_to receptions_path, notice: "Se elimino exitosamente la landing #{@reception.name}"
	end

	def register
		@user = User.unscoped.find_by(email: user_params[:email])
		@group = Group.find(user_params[:group_id])
		if @user.nil?
			@user = User.invite!(:email => user_params[:email], :first_name => user_params[:first_name], :group_id => user_params[:group_id], :last_name => user_params[:last_name], :phone_number => user_params[:phone_number]) do |u|
        u.skip_invitation = true
      end
      send_mail(@user, accept_user_invitation_url)
      flash[:notice] = "El correo electronico #{@user.email} a sido registrado, verifica tu email para completar el registro"
		elsif !@user.nil? && !@user.invitation_token.nil?
			@user.update(email: user_params[:email], first_name: user_params[:first_name], group_id: user_params[:group_id], :last_name => user_params[:last_name], :phone_number => user_params[:phone_number])
      @user.invite! do |u|
        u.skip_invitation = true
      end
      send_mail(@user, accept_user_invitation_url)
      flash[:notice] = "El correo electronico #{@user.email} a sido registrado, verifica tu email para completar el registro"
    elsif !@user.nil? && @user.invitation_token.nil?
      flash[:notice] = "El correo electronico #{@user.email} ya cuenta con una cuenta activa."
		end
		
		redirect_to	reception_path(@group.name)
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
      data = {
        personalizations: [
          {
            to: [ { email: user.email} ],
            substitutions: {
              "-confirmation_link-" => "#{url}?invitation_token=#{user.raw_invitation_token}"
            },
            subject: "Tu cuenta en EDC Digital ha sido creada"
          },
        ],
        from: {
          email: "soporte@edc-digital.com"
        },
        template_id: "506fcba3-80ce-4de9-bb7f-41e1e752ce0f"
      }


      sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
      
      begin
        response = sg.client.mail._("send").post(request_body: data)
        Rails.logger.info response.status_code
        Rails.logger.info response.body
        Rails.logger.info response.headers
        FakeEmail.new
      rescue Exception => e
        Rails.logger.info e.message
        FakeEmail.new
      end
  end	

end
