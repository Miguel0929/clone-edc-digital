class AddVideoUrlToLesson < ActiveRecord::Migration
  def change
    add_column :lessons, :video_url, :string

    change_column :questions, :support_text, :text
  end
end
