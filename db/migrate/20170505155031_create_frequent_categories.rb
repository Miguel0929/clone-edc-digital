class CreateFrequentCategories < ActiveRecord::Migration
  def change
    create_table :frequent_categories do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
