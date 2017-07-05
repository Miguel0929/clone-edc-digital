class Api::V1::UsersController < Api::V1::BaseController
  def index
    render json: search_users
  end

  private
  def search_users

    logger.info "Retrieveing users for #{current_user.role}"

    case current_user.role
    when 'admin'
      User.search(params[:search])
      .records
      .limit(5)
      .where(role: %w{1 0})
      .map { |user| serialize_user(user) }
    when 'mentor'
      User.search(params[:search])
      .records
      .limit(5)
      .where(role: %w{0})
      .map { |user| serialize_user(user) }
    end
  end

  def serialize_user(user)
    {
      id: user.id,
      name: user.name,
      email: user.email,
      phone_number: user.phone_number,
      role: user.role,
      url: path_for(user)
    }
  end

  def path_for(user)
    case user.role
    when "mentor"
      mentor_path(user)
    when "student"
      user_path(user)
    end
  end
end
