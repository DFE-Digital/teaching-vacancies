class Publishers::VacancyStats
  CACHE_DURATION = 6.hours
  TABLE_NAME = "vacancies_published".freeze

  def initialize(vacancy)
    @vacancy = vacancy
  end

  def number_of_unique_views
    field = :number_of_unique_vacancy_views
    fail_safe do
      Rails.cache.fetch([field, vacancy.id], expires_in: CACHE_DURATION, skip_nil: true) do
        # publish_on added to make query more efficient as the BigQuery table is partitioned by it
        #
        # Why do we search by both Vacancy real id and Anonymised vacancy id?
        # We stopped anonymising the Vacancy id in the data pushed to BigQ, but the existing BigQ data is associated to
        # the anonymised id. To reflect the real number of unique vacancy views, we are adding up any views associated
        # with the Vacancy anonymised id to the new views associated with the real Vacancy id.
        sql = <<~SQL
          SELECT SUM(#{field}) AS #{field}
          FROM `#{Rails.configuration.big_query_dataset}.#{TABLE_NAME}`
          WHERE id IN ("#{vacancy.id}", "#{StringAnonymiser.new(vacancy.id)}")
          AND publish_on = "#{vacancy.publish_on.iso8601}"
        SQL

        big_query.query(sql).first&.fetch(field) || 0
      end
    end
  end

  private

  attr_reader :vacancy

  def big_query
    @big_query ||= Google::Cloud::Bigquery.new
  end
end
