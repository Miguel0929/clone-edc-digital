class CreateProgramSequences < ActiveRecord::Migration
  def change
    create_table :program_sequences do |t|
      t.string :sequence
      t.references :group, index: true, foreign_key: true
    end
  end
end
