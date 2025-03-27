require "rails_helper"

RSpec.describe AggregateVacancyReferrerStatsJob do
  describe "#perform" do
    it "calls VacancyAnalyticsService.aggregate_and_save_stats" do
      expect(VacancyAnalyticsService).to receive(:aggregate_and_save_stats)

      described_class.new.perform
    end
  end
end
