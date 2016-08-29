class CreateGroupPrograms < ActiveRecord::Migration
  def change
    create_table :group_programs do |t|
      t.integer :group_id, index: true
      t.integer :program_id, index: true
    end
  end
end
