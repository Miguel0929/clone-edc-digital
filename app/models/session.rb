class Session < ActiveRecord::Base
  belongs_to :user

  def time
    return if start.nil? || finish.nil?

    if TimeDifference.between(start, finish).humanize.nil?
      "Menos de 1 segundo"
    else
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
  def minutes
    TimeDifference.between(start, finish).in_minutes
  end
end
