module DateHelper
  def format_date(date, format = :default)
    return if date.nil?
    raise "Unknown format: #{format} should be one of #{Date::DATE_FORMATS.keys.join(' ')}" unless Date::DATE_FORMATS.include?(format)
    date.to_s(format)
  end
end
