class AddPremiumToUsers < ActiveRecord::Migration
  def change
    add_column :users, :premium, :boolean, :null => false, :default => true
  end
end
