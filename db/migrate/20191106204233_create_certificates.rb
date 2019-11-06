class CreateCertificates < ActiveRecord::Migration
  def change
    create_table :certificates do |t|
      t.string :name
      t.string :email
      t.string :file
      t.integer :certificate_template_id
      t.string :batch
      t.string :date
      t.integer :mailing_status, :default => 0

      t.timestamps null: false
    end
  end
end
