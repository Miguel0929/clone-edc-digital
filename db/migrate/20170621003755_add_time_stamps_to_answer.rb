class AddTimeStampsToAnswer < ActiveRecord::Migration
  def change
    add_timestamps(:answers)
  end
end
