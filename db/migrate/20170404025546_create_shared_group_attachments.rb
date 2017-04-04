class CreateSharedGroupAttachments < ActiveRecord::Migration
  def change
    create_table :shared_group_attachments do |t|
      t.string   :file
      t.string   :label
      t.integer  :document_type
      t.string   :name
      t.integer   :owner_id

      t.timestamps
    end
  end
end
