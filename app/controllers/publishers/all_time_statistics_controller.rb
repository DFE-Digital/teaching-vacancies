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
          csv_data = CSV.generate(headers: false) do |csv|
            presenter = VacancyStatisticsPresenter.new(vacancies)
            presenter.equal_opportunities_data.each_value do |sorted_data|
              csv << sorted_data.keys
              csv << sorted_data.values
            end
          end

          send_data csv_data, filename: "equal_oppuntunities.csv"
        end
      end
    end
  end
end
