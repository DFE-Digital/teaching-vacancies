module Vacancies::Export::DwpFindAJob::NewAndEdited
  class Query
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

    # Vacancies that had over 30 days to expire when published, but now have reached exactly 30 days to expire.
    # These are selected to be exported, so we ensure the "expiry" date is set to 30 days in DWP Find a Job,
    # aligning the real TV vacancy expiration date with the Find a Job one.
    def vacancies_that_reached_expiry_date_threshold
      vacancies_published_before_date.where(expires_at: (Time.zone.now + FIND_A_JOB_MAX_EXPIRY_DAYS.days).all_day)
    end

    # Vacancies that have over 30 days to expire.
    # Since Find a Job vacancies expiry has a maximum of 30 days from when exported/updated, we need to regularly
    # push back the expiration date to "30 days from today" until the TV vacancies reaches its last 30 days live in the
    # service.
    # To achieve this regular updates, we select for export any TV vacancy that has over 30 days to expire and the
    # difference in days between the current expiration date and today is a multiple of 7 days.
    # This will cause vacancies to be exported every 7 days (pushing back their expiry on Find a Job service to 30 days)
    # until they reach the last 30 days of their live.
    def vacancies_that_need_expiry_date_pushed_back
      vacancies_published_before_date
        .where("expires_at > ?", Time.zone.now + FIND_A_JOB_MAX_EXPIRY_DAYS.days) # TV expiration date is over max Find a Job expiry (30 days)
        .where("DATE_PART('day', DATE_TRUNC('day', expires_at::timestamp) - '#{Date.today}'::date)::integer
                % 7 = 0") # TV expiration date is a multiple of 7 days from today
    end
  end
end
