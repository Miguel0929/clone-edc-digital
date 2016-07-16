class User < ActiveRecord::Base
  devise :database_authenticatable, :recoverable, :invitable, :validatable

  validates_presence_of :first_name, :last_name, :phone_number

  def name
    "#{first_name} #{last_name}"
  end
end
