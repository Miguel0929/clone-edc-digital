class AddArchivedToComments < ActiveRecord::Migration
  def change
    add_column :comments, :archived, :boolean, default: false
  end
end
