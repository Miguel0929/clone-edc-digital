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
        .gsub('Month', 'Mes')
        .gsub('Weeks', 'Semanas')
        .gsub('Week', 'Semana')
        .gsub('Days', 'Días')
        .gsub('Day', 'Día')
        .gsub('Hours', 'Horas')
        .gsub('Hour', 'Hora')
        .gsub('Minutes', 'Minutos')
        .gsub('Minute', 'Minuto')
        .gsub('Seconds', 'Segundos')
        .gsub('and', 'y')
    end
  end
  
  def day
    self.start.strftime('%Y-%m-%d')
  end

  def minutes
    TimeDifference.between(start, finish).in_minutes
  end

  def self.average
    total = 0
    all.each do |visit|
      total += visit.minutes
    end
    total / (self.count == 0 ? 1 : count)
  end

  def self.today
    total = 0
    visits = where(start: 1.day.ago...Time.now)
    visits.each do |visit|
      total += visit.minutes
    end
    total / (visits.count == 0 ? 1 : visits.count)
  end
end
