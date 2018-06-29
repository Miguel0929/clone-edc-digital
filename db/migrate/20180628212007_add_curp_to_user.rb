class AddCurpToUser < ActiveRecord::Migration
  def change
  	add_column :users, :curp, :string, :limit => 18
  end
end
