class AddDraftToRefilables < ActiveRecord::Migration
  def change
    add_column :refilables, :draft, :boolean, default: false
  end
end
