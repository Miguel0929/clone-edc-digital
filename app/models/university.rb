class University < ActiveRecord::Base
  belongs_to :state
  belongs_to :group
end
