module Vacancies::Export::DwpFindAJob::PublishedAndUpdatedVacancies
  class Query
    include Vacancies::Export::DwpFindAJob::Versioning

    attr_reader :from_date

    def initialize(from_date)
      @from_date = from_date
    end

    def vacancies
      vacancies_published_after_date
        .or(vacancies_updated_after_date)
        .or(vacancies_to_repost_today)
    end

    private

    def vacancies_published_after_date
      Vacancy.live.internal.where("publish_on > ?", from_date)
    end

    def vacancies_published_before_date
      Vacancy.live.internal.where("publish_on <= ?", from_date)
    end

    def vacancies_updated_after_date
      vacancies_published_before_date.where("updated_at > ?", from_date)
    end

    # Find a Job vacancies can only be posted up to 30 days from the original posting date.
    #
    # Vacancies in our service generally last well beyond 30 days, so we need to repost them as new job adverts in Find
    # a Job service every 31 days from the publish date, exactly when the previous advert has expired and the previous
    # version of the vacancy posting is no longer live.
    #
    # This query identifies all the live vacancies that, as today, need to be reposted as their publish date is a
    # multiple of 31 days ago.
    def vacancies_to_repost_today
      vacancies_published_before_date.where(
        "DATE_PART('day', DATE_TRUNC('day', '#{Date.today}'::date - publish_on::timestamp))::integer
        % #{DAYS_BETWEEN_REPOSTS} = 0",
      )
    end
  end
end
