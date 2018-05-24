class CreateEvaluationRefilables < ActiveRecord::Migration
  def change
    create_table :evaluation_refilables do |t|
    	t.references :template_refilable, index: true, foreign_key: true
      t.string :name
      t.integer :points

      t.string :excelent
      t.string :good
      t.string :regular
      t.string :bad
      t.integer :position
      t.timestamps null: false
    end
  end
end
