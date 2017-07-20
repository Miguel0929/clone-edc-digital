class CrearteDelireverableUsers < ActiveRecord::Migration
  def change
    create_table(:delireverable_users) do |t|
      t.integer :delireverable_id, index: true
      t.integer :user_id, index: true
      t.string :file
      t.text :comments
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
