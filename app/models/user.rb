class User < ActiveRecord::Base
  devise :invitable, :database_authenticatable, :recoverable

  validates_presence_of :first_name, :last_name, :phone_number, :password, :password_confirmation
  validates_confirmation_of :password
  validates_length_of :password, minimum: 8
end
