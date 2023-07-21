# Parses, when possible, the start date values coming from the external vacancy sources
class VacancySource::Parser::StartDate
  # EG: "04-09-2023", "4-9-23", "04/09/2023", "4/9/23", "04.09.2023"
  REGEXP_DATE_YEAR_END = %r{\d{1,2}[-\/\.]\d{1,2}[-\/\.][2-9]\d{1,3}}
  # EG: "2023-09-04", "23-9-4", "2023/09/04", "23/9/4", "2023.09.04"
  REGEXP_DATE_YEAR_START = %r{\d{2,4}[-\/\.]\d{1,2}[-\/\.]\d{1,2}}
  # Matches either of the above
  REGEXP_DATE = /(#{REGEXP_DATE_YEAR_START})|(#{REGEXP_DATE_YEAR_END})/
  # EG: "T12:00:00", "12:00:00"
  REGEXP_TIME = /T?\d\d:\d\d:\d\d/
  # EG: "2023-09-04T12:00:00", "2023-09-04 12:00:00", "2023-09-04"
  REGEXP_DATETIME = /#{REGEXP_DATE}\s?(#{REGEXP_TIME})?/
  # Ensures the whole string matches the above and no extra info comes together with a datetime value
  REGEXP_DATETIME_ONLY = /^#{REGEXP_DATETIME}$/

  # Types based on Vacancy#start_date_type values
  TYPE_SPECIFIC = "specific_date".freeze
  TYPE_OTHER = "other".freeze

  attr_reader :input, :type, :start_date

  def initialize(date)
    @input = date
    return if date.blank?

    parse_start_date(date)
  end

  def specific?
    type == TYPE_SPECIFIC
  end

  private

  def parse_start_date(date)
    date.strip!
    if date.match?(REGEXP_DATETIME_ONLY)
      @type = TYPE_SPECIFIC
      @start_date = Date.parse(year_first(remove_time(date))).to_s
    else
      @type = TYPE_OTHER
      @start_date = date
    end
  rescue Date::Error
    @type = TYPE_OTHER
    @start_date = @input # Records the original value if something goes wrong during the parsing.
  end

  # Removes the time part from a datetime string
  # EG: "2023-09-04T12:00:00" => "2023-09-04"
  def remove_time(date)
    time = date.match(REGEXP_TIME).try(:[], 0)
    return date unless time

    date.gsub(time, "").strip
  end

  # Reverses the order of the year and the day in a date string when the year is at the end
  # EG: "04-09-2023" => "2023-09-04"
  def year_first(date)
    return date unless date.match?(REGEXP_DATE_YEAR_END)

    separator = separator(date)
    date.split(separator).reverse.join(separator)
  end

  # Identifies the separator symbol used in the date ('-', '/' or '.')
  # EG: "04-09-2023" => "-"
  def separator(date)
    date.match(%r{[-\/\.]}).try(:[], 0)
  end
end
