module Vacancies::Export::DwpFindAJob::PublishedAndUpdatedVacancies
  class Query
    # Find a Job only accepts "expiry" dates up to 30 days from the date of export/update.
    FIND_A_JOB_MAX_EXPIRY_DAYS = 30

    attr_reader :from_date

    def initialize(from_date)
      @from_date = from_date
    end

    def vacancies
      vacancies_published_after_date
        .or(vacancies_updated_after_date)
        .or(vacancies_that_reached_expiry_date_threshold)
        .or(vacancies_that_need_expiry_date_pushed_back)
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

    # Vacancies in our service that had over 30 days to expire when published,
    # but as today have reached exactly 30 days to expire.
    #
    # Now we can select them to be exported so it will align Find a Job and TV expiration/closing dates.
    def vacancies_that_reached_expiry_date_threshold
      vacancies_published_before_date.where(expires_at: (Time.zone.now + FIND_A_JOB_MAX_EXPIRY_DAYS.days).all_day)
    end

    # Vacancies in our service that have over 30 days to expire.
    #
    # Since Find a Job vacancies have a maximum expiry date of 30 days from when exported/updated, we need to regularly
    # push back the expiration date onf Find a Job to "30 days from today" through the life of the vacancy in TV service.
    #
    # Every time we select them for exporting, it will push back their expiry date on Find a Job service to the max 30 days.
    #
    # To achieve this regular updates, we select for export any TV vacancy that::
    # - has over 30 days to expire
    # - the difference in days between today and the vacancy expiration date in TV is a multiple of 7 days.
    #
    # This will cause vacancies to be exported every 7 days (pushing back their expiry on Find a Job service to 30 days)
    # until they reach the last 30 days of their life.
    def vacancies_that_need_expiry_date_pushed_back
      vacancies_published_before_date
        .where("expires_at > ?", Time.zone.now + FIND_A_JOB_MAX_EXPIRY_DAYS.days)
        .where("DATE_PART('day', DATE_TRUNC('day', expires_at::timestamp) - '#{Date.today}'::date)::integer
                % 7 = 0") # TV expiration date is a multiple of 7 days from today
    end
  end
end
