require "rails_helper"

RSpec.describe VacancyFilterQuery do
  let!(:vacancy1) { create(:vacancy, job_title: "Vacancy 1", subjects: %w[English Spanish], working_patterns: %w[full_time], phases: %w[secondary], job_role: "teacher", ect_status: "ect_suitable") }
  let!(:vacancy2) { create(:vacancy, job_title: "Vacancy 2", subjects: %w[English Spanish], working_patterns: %w[full_time], phases: %w[sixth_form_or_college], job_role: "teacher", ect_status: "ect_unsuitable") }
  let!(:vacancy3) { create(:vacancy, job_title: "Vacancy 3", subjects: %w[English Spanish], working_patterns: %w[full_time], phases: %w[primary], job_role: "sendco", ect_status: nil) }

  describe "#call" do
    it "queries based on the given filters" do
      filters = {
        subjects: %w[English Spanish],
        working_patterns: %w[full_time],
        phases: %w[secondary],
        job_roles: %w[teacher],
        ect_statuses: %w[ect_suitable],
        from_date: 5.days.ago,
        to_date: Date.today,
      }
      expect(subject.call(filters)).to contain_exactly(vacancy1)
    end

    it "transforms legacy phases filters to new ones" do
      filters = {
        phases: %w[16-19],
      }
      expect(subject.call(filters)).to contain_exactly(vacancy2)
    end

    it "transforms legacy job role filters to new ones" do
      filters = {
        job_roles: %w[sen_specialist],
      }
      expect(subject.call(filters)).to contain_exactly(vacancy3)
    end
  end
end
