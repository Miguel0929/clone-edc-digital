class CreatesRefilables < ActiveRecord::Migration
  def change
    create_table :refilables do |t|
      t.integer :template_refilable_id, index: true
      t.integer :user_id, index: true
      t.text :content

      t.timestamps
    end
  end
end
