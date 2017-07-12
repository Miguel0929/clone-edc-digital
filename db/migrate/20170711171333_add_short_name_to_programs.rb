class AddShortNameToPrograms < ActiveRecord::Migration
  def change
    add_column :programs, :short_name, :string
  end
end
