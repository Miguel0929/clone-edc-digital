class User < ActiveRecord::Base
  devise :invitable, :database_authenticatable, :recoverable
end
