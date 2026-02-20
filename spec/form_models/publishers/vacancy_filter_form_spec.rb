require "rails_helper"

RSpec.describe Publishers::VacancyFilterForm do
  describe "#initialize" do
    it "sets organisation_ids from params" do
      form = described_class.new(organisation_ids: %w[123 456])
      expect(form.organisation_ids).to eq(%w[123 456])
    end

    it "sets job_roles from params" do
      form = described_class.new(job_roles: %w[teacher headteacher])
      expect(form.job_roles).to eq(%w[teacher headteacher])
    end

    it "defaults organisation_ids to empty array when not provided" do
      form = described_class.new
      expect(form.organisation_ids).to eq([])
    end

    it "defaults job_roles to empty array when not provided" do
      form = described_class.new
      expect(form.job_roles).to eq([])
    end
  end

  describe "#to_hash" do
    it "returns hash with both filters" do
      form = described_class.new(organisation_ids: %w[123 456], job_roles: %w[teacher headteacher])
      expect(form.to_hash).to eq({ organisation_ids: %w[123 456], job_roles: %w[teacher headteacher] })
    end

    it "removes blank values from hash" do
      form = described_class.new(organisation_ids: [], job_roles: [])
      expect(form.to_hash).to eq({})
    end
  end
end
