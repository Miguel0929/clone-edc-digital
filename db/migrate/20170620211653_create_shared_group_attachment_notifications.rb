class CreateSharedGroupAttachmentNotifications < ActiveRecord::Migration
  def change
    create_table :shared_group_attachment_notifications do |t|
      t.references :shared_group_attachment, index: {name: "index_share_group_attachment_notifications"}, foreign_key: true

      t.timestamps null: false
    end
  end
end
