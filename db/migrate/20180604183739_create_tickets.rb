class CreateTickets < ActiveRecord::Migration
  def up
    create_table :tickets do |t|
      t.integer :element_id
      t.integer :coach_id
      t.integer :trainee_id
      t.integer :category
      t.string :title
      t.boolean :closed, default: false
      t.timestamps null: false
    end
  end

  def down
    drop_table :tickets
  end
end
