module DateHelper
  class FormatDateError < RuntimeError; end

  def format_date(date, format = :default)
    return 'No date given' if date.nil?

    unless Date::DATE_FORMATS.include?(format)
      raise FormatDateError, date_format_error_message(format, Date::DATE_FORMATS.keys.join(' '))
    end

    date.to_s(format).lstrip
  end

  def format_time(time)
    return '' if time.nil?

    time.strftime('%-l:%M %P')
  end

  def date_format_error_message(format, date_formats)
    "Unknown format: #{format} should be one of #{date_formats}"
  end

  def compose_expiry_time(args)
    return nil if [args[:hour],
                   args[:min],
                   args[:meridiem]].any? { |attr| attr.to_s.empty? }

    return nil unless in_range?(args[:hour], 1, 12)
    return nil unless in_range?(args[:min], 0, 59)

    expiry_time_string = "#{args[:day]}-#{args[:month]}-#{args[:year]}" \
                         " #{args[:hour]}:#{args[:min]} #{args[:meridiem]}"

    Time.zone.parse(expiry_time_string)
  end

  def format_datetime_with_seconds(str)
    return nil if str.nil?

    date_time = Time.zone.parse(str)
    "#{date_time}:#{date_time.strftime('%S')}"
  end

  private

  def in_range?(value, min, max)
    number?(value) && value.to_i >= min && value.to_i <= max
  end

  def number?(value)
    /\A[+-]?\d+\z/.match?(value.to_s)
  end
end
