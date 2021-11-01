require "rails_helper"

RSpec.describe VacancyFilterQuery do
  let(:organisation1) { create(:school, readable_phases: %w[primary middle]) }
  let(:organisation2) { create(:school, readable_phases: %w[secondary 16-19]) }

  let!(:vacancy1) { create(:vacancy, subjects: %w[German French], working_patterns: %w[full_time], job_roles: %w[leadership], organisations: [organisation1]) }
  let!(:vacancy2) { create(:vacancy, subjects: %w[English Spanish], working_patterns: %w[full_time], phase: :primary, job_roles: %w[teacher]) }
  let!(:vacancy3) { create(:vacancy, subjects: %w[German Spanish], working_patterns: %w[part_time], job_roles: %w[leadership], organisations: [organisation1]) }
  let!(:vacancy4) { create(:vacancy, subjects: %w[Media German], working_patterns: %w[full_time part_time], job_roles: %w[send_responsible], organisations: [organisation2]) }
  let!(:vacancy5) { create(:vacancy, subjects: %w[German Spanish], working_patterns: %w[term_time], job_roles: %w[leadership], organisations: [organisation2]) }

  describe "#call" do
    it "queries based on the given filters" do
      filters = {
        subjects: %w[Spanish German],
        working_patterns: %w[full_time],
        phases: %w[primary 16-19],
        job_roles: %w[leadership send_responsible],
        from_date: 5.days.ago,
        to_date: Date.today,
      }
      expect(subject.call(filters)).to contain_exactly(vacancy1, vacancy4)
    end

    it "transforms legacy filters" do
      filters = {
        job_roles: %w[nqt_suitable sen_specialist],
      }
      expect(subject.call(filters)).to contain_exactly(vacancy4)
    end
  end
end
