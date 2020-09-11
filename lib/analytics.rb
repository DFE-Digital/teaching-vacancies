require 'google/apis/analytics_v3'

class Analytics
  API = Google::Apis::AnalyticsV3
  METRICS = 'ga:pageviews'.freeze
  ONEWEEKAGO = '7daysAgo'.freeze
  TODAY = 'today'.freeze

  attr_reader :service, :path, :start_date, :end_date

  def initialize(path, start_date = '30daysAgo', end_date = 'today')
    return if api_key_empty?

    @service = API::AnalyticsService.new
    @start_date = start_date
    @end_date = end_date
    @path = path
  end

  def call
    ga_data
    self
  end

  def pageviews
    ga_data.totals_for_all_results[METRICS]
  end

private

  def ga_data
    @ga_data ||= service.get_ga_data(GOOGLE_ANALYTICS_PROFILE_ID, start_date, end_date,
                                     METRICS, filters: filters)
  end

  def filters
    "ga:pagePath==#{path}"
  end

  def api_key_empty?
    GOOGLE_API_JSON_KEY.empty? || JSON.parse(GOOGLE_API_JSON_KEY).empty?
  end
end
