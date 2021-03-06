class Api::V1::StaticLoginController < Api::V1::BaseController
  def create
    binding.pry
    user = User.authenticate(params[:email], params[:password])

    if user
      user.generate_authentication_token
      render json: user, status: :ok
    else
      render json: { error: 'invalid credentials' }, status: 401
    end
  end
end
