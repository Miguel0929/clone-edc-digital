class CreateRouteCovers < ActiveRecord::Migration
  def change
    create_table :route_covers do |t|
      t.string :name
      t.string :image

      t.timestamps null: false
    end
  end
end
