module DateHelper
  def format_date(date, format = :default)
    return if date.nil?
    date_formats = Date::DATE_FORMATS.keys.join(' ')
    raise "Unknown format: #{format} should be one of #{date_formats}" \
      unless Date::DATE_FORMATS.include?(format)
    date.to_s(format)
  end
end
