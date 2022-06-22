module DatesHelper
  def format_time_to_datetime_at(time)
    return unless time.present?

    [format_date(time.to_date), I18n.t("jobs.time_at"), format_time(time)].join(" ")
  end

  def format_date(date, format = :default)
    return "No date given" unless date.present?

    date.to_formatted_s(format).lstrip
  end

  def format_time(time, format = :time_only)
    return unless time.present?

    time.to_formatted_s(format).lstrip
  end

  def day(date)
    if date.today?
      "Today"
    elsif date.yesterday?
      "Yesterday"
    else
      date.strftime("%-d %B")
    end
  end

  def days_to_apply(date)
    case date
    when Date.current
      t("jobs.days_to_apply.today")
    when Date.tomorrow
      t("jobs.days_to_apply.tomorrow")
    else
      t("jobs.days_to_apply.remaining", days_remaining: (date - Date.current).to_i)
    end
  end
end
