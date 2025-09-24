module Publishers
  class StatisticsController < BaseController
    private

    def vacancies
      PublishedVacancy.in_organisation_ids(current_publisher.accessible_organisations(current_organisation).map(&:id))
    end
  end
end
