# frozen_string_literal: true

module Publishers
  class AllTimeStatisticsController < StatisticsController
    def index
      respond_to do |format|
        format.csv do
          presenter = VacancyStatisticsPresenter.new(vacancies)
          data = presenter.referrer_counts
          csv_data = CSV.generate(headers: false) do |csv|
            csv << data.keys
            csv << data.values
          end

          send_data csv_data, filename: "statistics.csv"
        end
      end
    end

    def equal_opportunities
      respond_to do |format|
        format.csv do
          rows = VacancyStatisticsPresenter.new(vacancies).equal_opportunities_csv

          csv_data = CSV.generate(headers: false) { |csv| rows.each { |r| csv << r } }

          send_data csv_data, filename: "equal_opportunities.csv"
        end
      end
    end
  end
end
