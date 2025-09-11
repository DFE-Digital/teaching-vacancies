# frozen_string_literal: true

require "rails_helper"

RSpec.describe VacancyAnalytics do
  describe "#tidy_stats" do
    before do
      model.tidy_stats
    end

    context "with only bot stats" do
      let(:model) { build_stubbed(:vacancy_analytics, referrer_counts: { "direct" => 24, "facebook" => 17 }) }

      it "removes the bots" do
        expect(model.referrer_counts).to eq({ "facebook" => 17 })
      end
    end

    context "with bots and production" do
      let(:model) { build_stubbed(:vacancy_analytics, referrer_counts: { "direct" => 24, "facebook" => 17, VacancyAnalytics::PRODUCTION_SERVICE_NAME => 65 }) }

      it "converts self-refs to direct" do
        expect(model.referrer_counts).to eq({ "facebook" => 17, "direct" => 65 })
      end
    end
  end
end
