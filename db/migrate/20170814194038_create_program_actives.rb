class CreateProgramActives < ActiveRecord::Migration
  def change
    create_table :program_actives do |t|
      t.references :user, index: true, foreign_key: true
      t.references :program, index: true, foreign_key: true
      t.boolean :status

      t.timestamps null: false
    end
  end
end
