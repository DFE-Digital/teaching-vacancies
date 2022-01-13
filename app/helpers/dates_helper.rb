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
end
