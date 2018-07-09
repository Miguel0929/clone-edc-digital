class CreateRefilableDefaultComments < ActiveRecord::Migration

  def change
    create_table :refilable_default_comments do |t|
      t.string :name
      t.text :content
      t.references :template_refilable, index: true, foreign_key: true
      t.timestamps null: false
    end
  end

end
