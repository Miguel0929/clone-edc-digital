class Visit < ActiveRecord::Base
  has_many :ahoy_events, class_name: "Ahoy::Event"
  belongs_to :user

  def session_time
    return if started_at.nil? || finished_at.nil?

    TimeDifference.between(started_at, finished_at)
      .humanize
      .gsub('Years', 'Año')
      .gsub('Months', 'Meses')
      .gsub('Weeks', 'Semanas')
      .gsub('Days', 'Dias')
      .gsub('Hours', 'Horas')
      .gsub('Minutes', 'Minutos')
      .gsub('Seconds', 'Segundos')
      .gsub('and', 'y')
  end
end
