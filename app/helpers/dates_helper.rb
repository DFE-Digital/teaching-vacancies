module DatesHelper
  def format_time_to_datetime_at(time)
    return "" if time.nil?

    [format_date(time.to_date), I18n.t("jobs.time_at"), format_time(time)].join(" ")
  end

  def format_date(date, format = :default)
    return "No date given" if date.nil?

    date.to_s(format).lstrip
  end

  def format_time(time, format = :time_only)
    return "" if time.nil?

    time.to_s(format).lstrip
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
