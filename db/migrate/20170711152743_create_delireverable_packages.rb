class CreateDelireverablePackages < ActiveRecord::Migration
  def change
    create_table :delireverable_packages do |t|
      t.string :name
      t.text   :description
      t.timestamps
    end

    create_table :group_delireverable_packages do |t|
      t.integer :group_id, index: true
      t.integer :delireverable_package_id, index: true
    end
  end
end
