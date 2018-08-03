class AddTrialToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :trial, :boolean, :null => false, :default => false
    add_column :groups, :group_premium_id, :integer
  end
end
