class AddAgeToUsers < ActiveRecord::Migration
  def up
    add_column :users, :age, :integer
  end

  def down
  	remove_column :users, :age, :integer
  end
end
