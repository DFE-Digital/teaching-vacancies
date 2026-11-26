module Publishers
  class StatisticsController < BaseController
    private

    def vacancies
      Vacancy.in_organisation_ids(current_publisher.accessible_organisations(current_organisation).map(&:id))
    end
  end
end
