class AddDescriptionAndCoverToProgram < ActiveRecord::Migration
  def change
    add_column :programs, :description, :text
    add_column :programs, :cover, :string
  end
end
