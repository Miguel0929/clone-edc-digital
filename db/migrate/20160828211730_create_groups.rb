class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.string :name
      t.string :key

      t.datetime :deleted_at, index: true
      t.timestamps null: false
    end
  end
end
