class Period
  KEYS = %w[this_month last_30 last_90 this_year all].freeze

  def self.key(value)
    KEYS.include?(value.to_s) ? value.to_s : "all"
  end

  def self.label(value)
    I18n.t("periods.#{key(value)}")
  end

  def self.parse(value, today: Date.current)
    case key(value)
    when "this_month"
      today.all_month
    when "last_30"
      (today - 29)..today
    when "last_90"
      (today - 89)..today
    when "this_year"
      today.all_year
    end
  end
end
