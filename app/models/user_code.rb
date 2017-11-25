class UserCode < ActiveRecord::Base
  belongs_to :user
  validates_uniqueness_of :codigo
end
