class RemoveUniversityFromGroup < ActiveRecord::Migration
  def change
    remove_column :groups, :university, :string
  end
end
