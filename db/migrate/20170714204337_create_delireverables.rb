class CreateDelireverables < ActiveRecord::Migration
  def change
    create_table :delireverables do |t|
      t.integer :delireverable_package_id
      t.string :name
      t.text :description
      t.string :file
      t.integer :position

      t.timestamps
    end
  end
end
