class CreateMailboxAttachments < ActiveRecord::Migration
  def change
    create_table :mailbox_attachments do |t|
      t.string :file
      t.string :message_id
      t.timestamps null: false
    end
  end
end
