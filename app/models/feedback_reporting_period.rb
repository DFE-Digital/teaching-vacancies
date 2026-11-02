class FeedbackReportingPeriod
  include Comparable

  def self.for(dateish)
    date = parse_date(dateish)

    new(from: date.at_beginning_of_month, to: date.at_end_of_month)
  end

  def self.all
    first_feedback = Feedback.order(:created_at).first
    return [] if first_feedback.nil?

    Enumerator.new { |dates|
      date = self.for(first_feedback.created_at).from

      while date <= Date.today
        dates << self.for(date)
        date += 1.month
      end
    }.to_a
  end

  def initialize(from:, to:)
    @from = parse_date(from)
    @to = parse_date(to)
  end

  def <=>(other)
    @from <=> other.from
  end

  def ==(other)
    @from == other.from && @to == other.to
  end

  def to_s
    "#{@from.strftime('%F')} to #{@to.strftime('%F')}"
  end

  def date_range
    (@from.beginning_of_day)..(@to.end_of_day)
  end

  def self.parse_date(dateish)
    case dateish
    when DateTime, Time
      dateish.to_date
    when String
      Date.parse(dateish)
    when Date
      dateish
    else
      # This path should never be executed. so testing it is not useful
      # simplecov:disable
      raise ArgumentError, "Unsupported date type #{dateish.class.name}"
      # simplecov:enable
    end
  end

  attr_reader :from, :to

  private

  def parse_date(...)
    self.class.parse_date(...)
  end
end
