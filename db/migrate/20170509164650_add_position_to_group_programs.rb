class AddPositionToGroupPrograms < ActiveRecord::Migration
  def change
    add_column :group_programs, :position, :integer
  end
end
