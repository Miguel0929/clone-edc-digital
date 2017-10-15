class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :authentication_token, :first_name, :last_name, :profile_picture_url, :user_progress, :user_seen
  belongs_to :group
  belongs_to :industry

  def profile_picture_url
    object.profile_picture.url
  end
end
