class InterviewCalendar
  WEEKDAYS = %w[日 月 火 水 木 金 土].freeze

  attr_reader :month

  def initialize(interviews, month)
    @interviews = interviews
    @month = month.to_date.beginning_of_month
  end

  def weeks
    dates.each_slice(7).to_a
  end

  def events_on(date)
    grouped[date] || []
  end

  def prev_param
    month.prev_month.strftime("%Y-%m")
  end

  def next_param
    month.next_month.strftime("%Y-%m")
  end

  private

  def dates
    start_on = month.beginning_of_week(:sunday)
    end_on = month.end_of_month.end_of_week(:sunday)
    (start_on..end_on).to_a
  end

  def grouped
    @grouped ||= @interviews.group_by { |interview| interview.starts_at.in_time_zone.to_date }
  end
end
