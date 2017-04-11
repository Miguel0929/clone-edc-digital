class CreateSharedAtachments < ActiveRecord::Migration
  def change
    create_table :shared_attachments do |t|
      t.integer  :user_id
      t.string   :file
      t.string   :label
      t.integer  :document_type
      t.string   :name
      t.integer   :owner_id

      t.timestamps
    end
  end
end
