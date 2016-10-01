class AddSupportImageToQuestion < ActiveRecord::Migration
  def change
    add_column :questions, :support_image, :string
  end
end
