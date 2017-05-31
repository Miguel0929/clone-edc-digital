class CreateGlossaryCategories < ActiveRecord::Migration
  def change
    create_table :glossary_categories do |t|
      t.string :title

      t.timestamps null: false
    end
  end
end
