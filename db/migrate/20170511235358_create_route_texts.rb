class CreateRouteTexts < ActiveRecord::Migration
  def change
    create_table :route_texts do |t|
      t.string :name
      t.text :redaction

      t.timestamps null: false
    end
  end
end
