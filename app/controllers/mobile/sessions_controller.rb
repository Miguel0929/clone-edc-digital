class Mobile::SessionsController < Mobile::BaseController
  def create
    user = User.authenticate(params[:email], params[:password])

    if user
      generate_authentication_token(user)
      render json: user, status: :ok
    else
      render json: { error: 'invalid credentials' }, status: 401
    end
  end

  private
  def generate_authentication_token
    if user.authentication_token.blank?
      user.authentication_token = loop do
        token = Devise.friendly_token
        break token if token_suitable?(token)
      end

      self.save
    end
  end

  def token_suitable?(token)
    User.where(authentication_token: token).count == 0
  end
end
