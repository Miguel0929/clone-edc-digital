class CreateReportNotifications < ActiveRecord::Migration
  def change
    create_table :report_notifications do |t|
      t.references :report, index: true, foreign_key: true
      t.timestamps null: false
    end
  end
end
