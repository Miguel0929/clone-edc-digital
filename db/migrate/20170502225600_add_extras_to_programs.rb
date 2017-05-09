class AddExtrasToPrograms < ActiveRecord::Migration
  def change
    add_column :programs, :category, :string
    add_column :programs, :objetive, :text
    add_column :programs, :curriculum, :text
    add_column :programs, :icon, :string
    add_column :programs, :video, :string
    add_column :programs, :color, :string
  end
end
