class CreateExporters < ActiveRecord::Migration
  def change
    create_table :exporters do |t|
      t.string :file

      t.timestamps null: false
    end
  end
end
