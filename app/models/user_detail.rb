class UserDetail < ActiveRecord::Base
  validates_presence_of :user_id
  validates_uniqueness_of :user_id
  belongs_to :user
  nilify_blanks :only => [:situation, :interest, :challenge, :goal]
end