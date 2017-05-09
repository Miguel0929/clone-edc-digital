class CreateFrequents < ActiveRecord::Migration
  def change
    create_table :frequents do |t|
      t.text :name
      t.text :answer
      t.boolean :featured
      t.integer :frequent_category_id

      t.timestamps null: false
    end
  end
end
