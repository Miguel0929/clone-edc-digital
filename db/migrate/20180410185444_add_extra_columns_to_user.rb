class AddExtraColumnsToUser < ActiveRecord::Migration
  def up
  	remove_column :users, :age, :integer
    add_column :users, :birthdate, :date
    add_column :users, :situation, :string
    add_column :users, :interest, :string
    add_column :users, :challenge, :text
    add_column :users, :goal, :text
  end

  def down
  	add_column :users, :age, :integer
    remove_column :users, :birthdate, :date
    remove_column :users, :situation, :string
    remove_column :users, :interest, :string
    remove_column :users, :challenge, :text
    remove_column :users, :goal, :text
  end
end
