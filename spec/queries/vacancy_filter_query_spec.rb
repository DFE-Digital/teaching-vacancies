require "rails_helper"

RSpec.describe VacancyFilterQuery do
  let(:organisation1) { create(:school, readable_phases: %w[primary middle]) }
  let(:organisation2) { create(:school, readable_phases: %w[secondary 16-19]) }

  let!(:vacancy1) { create(:vacancy, job_title: "Vacancy 1", subjects: %w[German French], working_patterns: %w[full_time], job_roles: %w[senior_leader], organisations: [organisation1]) }
  let!(:vacancy2) { create(:vacancy, job_title: "Vacancy 2", subjects: %w[English Spanish], working_patterns: %w[full_time], phase: :primary, job_roles: %w[teacher]) }
  let!(:vacancy3) { create(:vacancy, job_title: "Vacancy 3", subjects: %w[German Spanish], working_patterns: %w[part_time], job_roles: %w[senior_leader], organisations: [organisation1]) }
  let!(:vacancy4) { create(:vacancy, job_title: "Vacancy 4", subjects: %w[Media German], working_patterns: %w[full_time part_time], job_roles: %w[send_responsible], organisations: [organisation2]) }
  let!(:vacancy5) { create(:vacancy, job_title: "Vacancy 5", subjects: %w[German Spanish], working_patterns: %w[term_time], job_roles: %w[senior_leader], organisations: [organisation2]) }
  let!(:vacancy6) { create(:vacancy, job_title: "Vacancy 6", subjects: %w[English Spanish], working_patterns: %w[full_time], phase: :primary, job_roles: %w[teacher ect_suitable]) }
  let!(:vacancy7) { create(:vacancy, job_title: "Vacancy 7", subjects: %w[English Spanish], working_patterns: %w[full_time], phase: :primary, job_roles: %w[teacher ect_suitable send_responsible]) }

  describe "#call" do
    it "queries based on the given filters" do
      filters = {
        subjects: %w[Spanish German],
        working_patterns: %w[full_time],
        phases: %w[primary 16-19],
        job_roles: %w[senior_leader],
        from_date: 5.days.ago,
        to_date: Date.today,
      }
      expect(subject.call(filters)).to contain_exactly(vacancy1)
    end

    it "transforms legacy job role filters to new ones" do
      filters = {
        job_roles: %w[nqt_suitable sen_specialist],
      }
      expect(subject.call(filters)).to contain_exactly(vacancy7)
    end

    it "requires *all* given additional job roles to be present" do
      expect(subject.call(job_roles: %w[teacher])).to contain_exactly(vacancy2, vacancy6, vacancy7)
      expect(subject.call(job_roles: %w[teacher ect_suitable]))
        .to contain_exactly(vacancy6, vacancy7)
      expect(subject.call(job_roles: %w[teacher ect_suitable send_responsible]))
        .to contain_exactly(vacancy7)
    end
  end
end
