class SharedGroupAttachmentGroups < ActiveRecord::Migration
  def change
    create_table :shared_group_attachment_groups do |t|
      t.integer :shared_group_attachment_id
      t.integer :group_id
    end
  end
end
