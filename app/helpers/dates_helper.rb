module DatesHelper
  class FormatDateError < RuntimeError; end

  def format_date(date, format = :default)
    return "No date given" if date.nil?

    date.to_s(format).lstrip
  end

  def format_time(time)
    return "" if time.nil?

    time.strftime("%-l:%M%P")
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
