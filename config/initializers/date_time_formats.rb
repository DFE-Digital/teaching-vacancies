# Format dates globally into this format:
Date::DATE_FORMATS[:default] = "%e %B %Y"
Date::DATE_FORMATS[:month_year] = "%B %Y"
Date::DATE_FORMATS[:day_month] = "%-d %B"

# Format times globally into these formats:
Time::DATE_FORMATS[:default] = "%e %B %Y %-l:%M%P"
Time::DATE_FORMATS[:date_only] = "%e %B %Y"
Time::DATE_FORMATS[:date_only_shorthand] = "%e %b %Y"
Time::DATE_FORMATS[:time_only] = "%-l:%M%P"
