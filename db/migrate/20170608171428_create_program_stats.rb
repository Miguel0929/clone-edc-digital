class CreateProgramStats < ActiveRecord::Migration
  def change
    create_table :program_stats do |t|
      t.integer :checked, default: 0
      t.references :user, index: true, foreign_key: true
      t.references :program, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
