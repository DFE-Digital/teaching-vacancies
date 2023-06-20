require "rails_helper"

RSpec.describe VacancyFilterQuery do
  let(:academies) { create(:school, name: "Academy1", school_type: "Academies") }
  let(:academy) { create(:school, name: "Academy2", school_type: "Academy") }
  let(:free_school) { create(:school, name: "Freeschool1", school_type: "Free schools") }
  let(:free_schools) { create(:school, name: "Freeschool2", school_type: "Free school") }
  let(:local_authority_school) { create(:school, name: "local authority", school_type: "Local authority maintained schools") }
  let!(:vacancy1) { create(:vacancy, job_title: "Vacancy 1", subjects: %w[English Spanish], working_patterns: %w[full_time], phases: %w[secondary], job_role: "teacher", ect_status: "ect_suitable", organisations: [academy]) }
  let!(:vacancy2) { create(:vacancy, job_title: "Vacancy 2", subjects: %w[English Spanish], working_patterns: %w[full_time], phases: %w[sixth_form_or_college], job_role: "teacher", ect_status: "ect_unsuitable", organisations: [free_school]) }
  let!(:vacancy3) { create(:vacancy, job_title: "Vacancy 3", subjects: %w[English Spanish], working_patterns: %w[full_time], phases: %w[primary], job_role: "sendco", ect_status: nil, organisations: [local_authority_school]) }
  let!(:vacancy4) { create(:vacancy, job_title: "Vacancy 4", subjects: %w[English Spanish], working_patterns: %w[full_time], phases: %w[primary], job_role: "teacher", ect_status: nil) }
  let!(:vacancy5) { create(:vacancy, job_title: "Vacancy 5", subjects: %w[English Spanish], working_patterns: %w[full_time], phases: %w[primary], job_role: "teacher", ect_status: nil, organisations: [academies]) }
  let!(:vacancy6) { create(:vacancy, job_title: "Vacancy 6", subjects: %w[English Spanish], working_patterns: %w[full_time], phases: %w[primary], job_role: "teacher", ect_status: nil, publisher_organisation: free_school, organisations: [free_school, free_schools]) }

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

    context "when organisation_types filter is selected" do
      context "when organisation_types == ['Academy']" do
        it "will return vacancies associated with academies and free schools" do
          filters = {
            organisation_types: ["Academy"],
          }
          expect(subject.call(filters)).to contain_exactly(vacancy1, vacancy2, vacancy5, vacancy6)
        end
      end

      context "when organisation_types == ['Local authority maintained schools']" do
        it "will return vacancies associated with local authority maintained schools" do
          filters = {
            organisation_types: ["Local authority maintained schools"],
          }
          expect(subject.call(filters)).to contain_exactly(vacancy3)
        end
      end

      context "when organisation_types is empty" do
        it "will return vacancies associated with all schools" do
          filters = {}
          expect(subject.call(filters)).to contain_exactly(vacancy1, vacancy2, vacancy3, vacancy4, vacancy5, vacancy6)
        end
      end

      context "when organisation_types includes both 'Academy' and 'Local authority maintained schools'" do
        it "will return vacancies associated with local authority maintained schools, academies and free schools" do
          filters = {
            organisation_types: ["Academy", "Local authority maintained schools"],

          }
          expect(subject.call(filters)).to contain_exactly(vacancy1, vacancy2, vacancy3, vacancy5, vacancy6)
        end
      end
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
