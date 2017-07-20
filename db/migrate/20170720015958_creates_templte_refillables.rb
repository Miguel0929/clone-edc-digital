class CreatesTemplteRefillables < ActiveRecord::Migration
  def change
    create_table(:template_refilables) do |t|
      t.string :name
      t.text :description
      t.text :content

      t.timestamps
    end

    create_table(:group_template_refilables) do |t|
      t.integer :group_id, index: true
      t.integer :template_refilable_id, index: true
    end
  end
end
