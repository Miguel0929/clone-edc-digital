class AddExtraFieldsToPrograms < ActiveRecord::Migration
  def change
    add_column :programs, :level, :integer
    add_column :programs, :tipo, :integer
  end
end
