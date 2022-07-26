# Format dates globally into this format:
Date::DATE_FORMATS[:default] = "%e %B %Y"
Date::DATE_FORMATS[:month_year] = "%B %Y"
Date::DATE_FORMATS[:day_month] = "%-d %B"

# Format times globally into these formats:
Time::DATE_FORMATS[:default] = "%e %B %Y %-l:%M%P"
Time::DATE_FORMATS[:date_only] = "%e %B %Y"
Time::DATE_FORMATS[:date_only_shorthand] = "%e %b %Y"
Time::DATE_FORMATS[:time_only] = lambda do |time|
  minutes = time.strftime("%M")
  hour = time.strftime("%-l")
  meridian = time.strftime("%P")

  if hour == "12" && minutes == "00" && meridian == "pm"
    time.strftime("%-l%P (midday)")
  elsif hour == "12" && minutes == "00" && meridian == "am"
    time.strftime("%-l%P (midnight)")
  elsif minutes == "00"
    time.strftime("%-l%P")
  else
    time.strftime("%-l:%M%P")
  end
end
