class Session < ActiveRecord::Base
  belongs_to :user

  def time
    return if start.nil? || finish.nil?

    TimeDifference.between(start, finish)
      .humanize
      .gsub('Years', 'Año')
      .gsub('Months', 'Meses')
      .gsub('Weeks', 'Semanas')
      .gsub('Days', 'Dias')
      .gsub('Hours', 'Horas')
      .gsub('Minutes', 'Minutos')
      .gsub('Minute', 'Minuto')
      .gsub('Seconds', 'Segundos')
      .gsub('and', 'y')
  end
end
