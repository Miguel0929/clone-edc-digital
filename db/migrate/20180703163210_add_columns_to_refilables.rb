class AddColumnsToRefilables < ActiveRecord::Migration
  def change
    add_column :refilables, :mentor_id, :integer
    add_column :refilables, :points, :integer
  end
end
