class ChangeRouteCoverColumn < ActiveRecord::Migration
  def change
  	rename_column :route_covers, :image, :route_image
  end
end
