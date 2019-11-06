class CreateCertificateTemplates < ActiveRecord::Migration
  def change
    create_table :certificate_templates do |t|
      t.string :name
      t.string :file

      t.timestamps null: false
    end
  end
end
