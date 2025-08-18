# frozen_string_literal: true

module Publishers
  class AllTimeStatisticsController < StatisticsController
    include StatisticsHelper

    def index
      respond_to do |format|
        format.csv do
          data = sort_referrer_counts(listing_data)
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
            equal_opportunities_data.each do |key, value|
              sorted_data = if key == :age
                              sort_age_stats(value)
                            else
                              sort_referrer_counts(value)
                            end
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
