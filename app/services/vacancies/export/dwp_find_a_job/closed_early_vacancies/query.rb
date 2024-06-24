module Vacancies::Export::DwpFindAJob::ClosedEarlyVacancies
  class Query
    attr_reader :from_date

    def initialize(from_date)
      @from_date = from_date
    end

    # Vacancies that are expired and that got updated within 60 seconds of their expiration date are
    # considered "early expired" in our service (a publisher manually closed them) and should be deleted from the
    # DWP Find a Job service.
    # The EXTRACT(EPOCH FROM...) query selects vacancies with a difference between the update and expiry timestamps
    # of 60 seconds max.
    def vacancies
      Vacancy.internal.expired
        .where("expires_at > ?", from_date)
        .where("EXTRACT(EPOCH FROM (updated_at::timestamp - expires_at::timestamp))::integer BETWEEN -60 AND 60")
    end
  end
end
