class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.string :cause
      t.boolean :status
      t.references :reportable, polymorphic: true, index: true

      t.timestamps null: false
    end
  end
end
