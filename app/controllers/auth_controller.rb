class AuthController < ApplicationController
  before_filter :authenticate_user_from_token!, :except => [:access_token]
  before_filter :authenticate_user!, :except => [:access_token]
  skip_before_filter :verify_authenticity_token, :only => [:access_token]

  def authorize
    AccessGrant.prune!
    create_hash = {
      client: application,
      state: params[:state]
    }
    access_grant = current_user.access_grants.create(create_hash)
    redirect_to access_grant.redirect_uri_for(params[:redirect_uri])
  end

  def access_token
    application = Client.authenticate(params[:client_id], params[:client_secret])

    if application.nil?
      render :json => {:error => "No se pudo encontrar la aplicación"}
      return
    end

    access_grant = AccessGrant.authenticate(params[:code], application.id)
    if access_grant.nil?
      render :json => {:error => "El código de acceso no pudo ser autenticado"}
      return
    end

    access_grant.start_expiry_period!
    render :json => {:access_token => access_grant.access_token, :refresh_token => access_grant.refresh_token, :expires_in => Devise.timeout_in.to_i}
  end

  def user
    hash = {
      provider: 'sso',
      id: current_user.id.to_s,
      info: {
         email: current_user.email,
      },
      extra: {
        first_name: current_user.first_name,
        last_name: current_user.last_name,
        phone_number: current_user.phone_number,
        role: current_user.role,
        groups: user_groups
      }
    }

    render :json => hash.to_json
  end

  protected

  def application
    @application ||= Client.find_by_app_id(params[:client_id])
  end

  private

  def authenticate_user_from_token!
    if params[:oauth_token]
      access_grant = AccessGrant.where(access_token: params[:oauth_token]).take
      if access_grant.user
        sign_in access_grant.user
      end
    end
  end

  def user_groups
    return [] if current_user.admin?
    if current_user.mentor?
      current_user.groups.pluck(:key)
    else
      [current_user.group.key]
    end
  end
end
