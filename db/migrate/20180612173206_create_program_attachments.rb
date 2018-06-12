class CreateProgramAttachments < ActiveRecord::Migration
  def change
    create_table :program_attachments do |t|

    	t.string   :file
      t.string   :label
      t.integer  :document_type
      t.string   :name
			t.references :program, index: true, foreign_key: true
      t.timestamps null: false
    end
  end
end
