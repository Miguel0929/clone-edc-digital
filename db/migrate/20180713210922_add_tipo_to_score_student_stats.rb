class AddTipoToScoreStudentStats < ActiveRecord::Migration
  def change
    add_column :score_student_stats, :tipo, :integer
  end
end
