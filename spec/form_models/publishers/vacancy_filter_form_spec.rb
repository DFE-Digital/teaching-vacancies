require "rails_helper"

RSpec.describe Publishers::VacancyFilterForm do
  describe "#initialize" do
    it "sets organisation_ids from params" do
      form = described_class.new(organisation_ids: %w[123 456])
      expect(form.organisation_ids).to eq(%w[123 456])
    end

    it "defaults organisation_ids to empty array when not provided" do
      form = described_class.new
      expect(form.organisation_ids).to eq([])
    end
  end

  describe "#to_hash" do
    it "returns hash with organisation_ids" do
      form = described_class.new(organisation_ids: %w[123 456])
      expect(form.to_hash).to eq({ organisation_ids: %w[123 456] })
    end

    it "removes blank values from hash" do
      form = described_class.new(organisation_ids: [])
      expect(form.to_hash).to eq({})
    end
  end
end
