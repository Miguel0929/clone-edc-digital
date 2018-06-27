class RemoveExtraColumnsToUser < ActiveRecord::Migration
  def change
    remove_column :users, :birthdate, :date
    remove_column :users, :situation, :string
    remove_column :users, :interest, :string
    remove_column :users, :challenge, :text
    remove_column :users, :goal, :text
  end
end
