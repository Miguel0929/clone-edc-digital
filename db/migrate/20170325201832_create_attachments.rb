class CreateAttachments < ActiveRecord::Migration
  def change
    create_table :attachments do |t|
      t.integer  :user_id
      t.string   :file
      t.string   :label
      t.integer  :document_type
      t.string   :name

      t.timestamps
    end
  end
end
