class ProgramActive < ActiveRecord::Base
  belongs_to :user
  belongs_to :program
end
