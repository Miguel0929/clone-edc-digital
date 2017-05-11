class AddSmallCoverToPrograms < ActiveRecord::Migration
  def change
    add_column :programs, :small_cover, :string
  end
end
