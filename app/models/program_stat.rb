class ProgramStat < ActiveRecord::Base
  belongs_to :user
  belongs_to :program

  validates :user_id, presence: true
  validates :program_id, presence: true

  def round_program_progress
  	progress = self.program_progress
  	progress.nil? ? "0" : progress.round.to_s
  end

  def round_program_seen
  	seen = self.program_seen
  	seen.nil? ? "0" : seen.round.to_s
  end

  def self.add_score
    stats = ProgramStat.where(checked: 1)
    stats.each do |stat|
      user = stat.user
      program = stat.program
      stat.update(score: program.evaluated_avg(user))
    end  
  end  
end
