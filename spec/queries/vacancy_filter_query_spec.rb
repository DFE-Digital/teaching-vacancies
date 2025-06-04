require "rails_helper"

RSpec.describe VacancyFilterQuery do
  subject { PublishedVacancy.kept.search_by_filter(filters) }

  before do
    create(:vacancy, :trashed, phases: %w[secondary], working_patterns: %w[part_time full_time], subjects: %w[English Spanish], ect_status: "ect_suitable")
  end

  let(:academies) { create(:school, name: "Academy1", school_type: "Academies") }
  let(:academy) { create(:school, name: "Academy2", school_type: "Academy") }
  let(:free_school) { create(:school, name: "Freeschool1", school_type: "Free schools") }
  let(:free_schools) { create(:school, name: "Freeschool2", school_type: "Free school") }
  let(:local_authority_school) { create(:school, name: "local authority", school_type: "Local authority maintained schools") }
  let(:special_school1) { create(:school, name: "Community special school", detailed_school_type: "Community special school") }
  let(:special_school2) { create(:school, name: "Foundation special school", detailed_school_type: "Foundation special school") }
  let(:special_school3) { create(:school, name: "Non-maintained special school", detailed_school_type: "Non-maintained special school") }
  let(:special_school4) { create(:school, name: "Academy special converter", detailed_school_type: "Academy special converter") }
  let(:special_school5) { create(:school, name: "Academy special sponsor led", detailed_school_type: "Academy special sponsor led") }
  let(:special_school6) { create(:school, name: "Non-maintained special school", detailed_school_type: "Free schools special") }
  let(:faith_school) { create(:school, name: "Religious", gias_data: { "ReligiousCharacter (name)" => "anything" }) }
  let(:faith_school2) { create(:school, name: "Religious", gias_data: { "ReligiousCharacter (name)" => "somethingelse" }) }
  let(:non_faith_school1) { create(:school, name: "nonfaith1", gias_data: { "ReligiousCharacter (name)" => "" }) }
  let(:non_faith_school2) { create(:school, name: "nonfaith2", gias_data: { "ReligiousCharacter (name)" => "Does not apply" }) }
  let(:non_faith_school3) { create(:school, name: "nonfaith3", gias_data: { "ReligiousCharacter (name)" => "None" }) }

  # Subjects are ignored when phases are primary-only
  let!(:vacancy1) { create(:vacancy, job_title: "Vacancy 1", subjects: %w[English Spanish], working_patterns: %w[part_time full_time], phases: %w[secondary], ect_status: "ect_suitable", organisations: [academy], enable_job_applications: true, visa_sponsorship_available: true) }
  let!(:vacancy2) { create(:vacancy, job_title: "Vacancy 2", subjects: %w[English Spanish], phases: %w[sixth_form_or_college], ect_status: "ect_unsuitable", organisations: [free_school], enable_job_applications: true) }
  let!(:vacancy3) { create(:vacancy, job_title: "Vacancy 3", phases: %w[primary], job_roles: ["sendco"], organisations: [local_authority_school], enable_job_applications: true) }
  let!(:vacancy4) { create(:vacancy, :no_tv_applications, job_title: "Vacancy 4", phases: %w[primary]) }
  let!(:vacancy5) { create(:vacancy, :no_tv_applications, job_title: "Vacancy 5", phases: %w[primary], job_roles: ["head_of_year_or_phase"], organisations: [academies]) }
  let!(:vacancy6) { create(:vacancy, :no_tv_applications, job_title: "Vacancy 6", phases: %w[primary], job_roles: ["head_of_department_or_curriculum"], publisher_organisation: free_school, organisations: [free_school, free_schools]) }
  let!(:vacancy7) { create(:vacancy, :no_tv_applications, job_title: "Vacancy 7", phases: %w[primary], job_roles: ["headteacher"], publisher_organisation: free_school, organisations: [free_school, free_schools]) }
  let!(:vacancy8) { create(:vacancy, :no_tv_applications, job_title: "Vacancy 8", phases: %w[primary], job_roles: ["assistant_headteacher"], publisher_organisation: free_school, organisations: [free_school, free_schools]) }
  let!(:vacancy9) { create(:vacancy, :no_tv_applications, job_title: "Vacancy 9", phases: %w[primary], job_roles: ["deputy_headteacher"], publisher_organisation: free_school, organisations: [free_school, free_schools]) }
  let!(:teaching_assistant_vacancy) { create(:vacancy, :no_tv_applications, job_title: "Vacancy 10", phases: %w[primary], job_roles: ["teaching_assistant"], publisher_organisation: free_school, organisations: [free_school, free_schools]) }
  let!(:hlta_vacancy) { create(:vacancy, :no_tv_applications, job_title: "Vacancy 11", phases: %w[primary], job_roles: ["higher_level_teaching_assistant"], publisher_organisation: free_school, organisations: [free_school, free_schools]) }
  let!(:education_support_vacancy) { create(:vacancy, :no_tv_applications, job_title: "Vacancy 12", phases: %w[primary], job_roles: ["education_support"], publisher_organisation: free_school, organisations: [free_school, free_schools]) }
  let!(:sendco_vacancy) { create(:vacancy, :no_tv_applications, job_title: "Vacancy 13", phases: %w[primary], job_roles: ["sendco"], publisher_organisation: free_school, organisations: [free_school, free_schools]) }
  let!(:administration_hr_data_and_finance_vacancy) { create(:vacancy, :no_tv_applications, job_title: "Vacancy 15", phases: %w[primary], job_roles: ["administration_hr_data_and_finance"], publisher_organisation: free_school, organisations: [free_school, free_schools]) }
  let!(:it_support_vacancy) { create(:vacancy, :no_tv_applications, job_title: "Vacancy 16", phases: %w[primary], job_roles: ["it_support"], publisher_organisation: free_school, organisations: [free_school, free_schools]) }
  let!(:pastoral_health_and_welfare_vacancy) { create(:vacancy, :no_tv_applications, job_title: "Vacancy 17", phases: %w[primary], job_roles: ["pastoral_health_and_welfare"], publisher_organisation: free_school, organisations: [free_school, free_schools]) }
  let!(:other_leadership_vacancy) { create(:vacancy, :no_tv_applications, job_title: "Vacancy 18", phases: %w[primary], job_roles: ["other_leadership"], publisher_organisation: free_school, organisations: [free_school, free_schools]) }
  let!(:other_support_vacancy) { create(:vacancy, :no_tv_applications, job_title: "Vacancy 19", phases: %w[primary], job_roles: ["other_support"], publisher_organisation: free_school, organisations: [free_school, free_schools], expires_at: 2.days.from_now) }
  let!(:catering_cleaning_and_site_management_vacancy) { create(:vacancy, :no_tv_applications, job_title: "Vacancy 19", phases: %w[primary], job_roles: ["catering_cleaning_and_site_management"], publisher_organisation: free_school, organisations: [free_school, free_schools], expires_at: 1.day.from_now) }

  let!(:special_vacancy1) { create(:vacancy, :no_tv_applications, job_title: "Vacancy 7", phases: %w[primary], organisations: [special_school1]) }
  let!(:special_vacancy2) { create(:vacancy, :no_tv_applications, job_title: "Vacancy 8", phases: %w[primary], organisations: [special_school2]) }
  let!(:special_vacancy3) { create(:vacancy, :no_tv_applications, job_title: "Vacancy 9", phases: %w[primary], organisations: [special_school3]) }
  let!(:special_vacancy4) { create(:vacancy, :no_tv_applications, job_title: "Vacancy 10", phases: %w[primary], organisations: [special_school4]) }
  let!(:special_vacancy5) { create(:vacancy, :no_tv_applications, job_title: "Vacancy 11", phases: %w[primary], organisations: [special_school5]) }
  let!(:special_vacancy6) { create(:vacancy, :no_tv_applications, job_title: "Vacancy 12", phases: %w[primary], organisations: [special_school6]) }
  let!(:faith_vacancy) { create(:vacancy, :no_tv_applications, job_title: "Vacancy 13", phases: %w[primary], publisher_organisation: faith_school, organisations: [faith_school, faith_school2]) }
  let!(:non_faith_vacancy1) { create(:vacancy, :no_tv_applications, job_title: "Vacancy 14", phases: %w[primary], organisations: [non_faith_school1]) }
  let!(:non_faith_vacancy2) { create(:vacancy, :no_tv_applications, job_title: "Vacancy 15", phases: %w[primary], organisations: [non_faith_school2]) }
  let!(:non_faith_vacancy3) { create(:vacancy, :no_tv_applications, job_title: "Vacancy 14", phases: %w[primary], organisations: [non_faith_school3], visa_sponsorship_available: true) }

  describe "#call" do
    context "with english spanish" do
      let(:filters) do
        {
          subjects: %w[English Spanish],
          working_patterns: %w[full_time],
          phases: %w[secondary],
          teaching_job_roles: %w[teacher],
          ect_statuses: %w[ect_suitable],
          from_date: 5.days.ago,
          to_date: Date.today,
        }
      end

      it "queries based on the given filters" do
        expect(subject).to contain_exactly(vacancy1)
      end
    end

    context "when visa_sponsorship_available is selected" do
      let(:filters) { { visa_sponsorship_availability: ["true"] } }

      it "will return vacancies that offer visa sponsorships" do
        expect(subject).to contain_exactly(vacancy1, non_faith_vacancy3)
      end
    end

    context "when organisation_types filter is selected" do
      context "when organisation_types == ['Academy']" do
        let(:filters) { { organisation_types: ["Academy"] } }

        it "will return vacancies associated with academies and free schools" do
          expect(subject)
            .to contain_exactly(vacancy1, vacancy2, vacancy5, vacancy6, vacancy7, vacancy8, vacancy9, teaching_assistant_vacancy,
                                hlta_vacancy, education_support_vacancy, sendco_vacancy,
                                administration_hr_data_and_finance_vacancy, it_support_vacancy, pastoral_health_and_welfare_vacancy,
                                other_leadership_vacancy, other_support_vacancy, catering_cleaning_and_site_management_vacancy)
        end
      end

      context "when organisation_types == ['Local authority maintained schools']" do
        let(:filters) { { organisation_types: ["Local authority maintained schools"] } }

        it "will return vacancies associated with local authority maintained schools" do
          expect(subject).to contain_exactly(vacancy3)
        end
      end

      context "when organisation_types is empty" do
        let(:filters) { {} }

        it "will return vacancies associated with all schools" do
          expect(subject).to contain_exactly(
            vacancy1, vacancy2, vacancy3, vacancy4, vacancy5, vacancy6, vacancy7, vacancy8, vacancy9, special_vacancy1,
            special_vacancy2, special_vacancy3, special_vacancy4, special_vacancy5, special_vacancy6, faith_vacancy,
            non_faith_vacancy1, non_faith_vacancy2, non_faith_vacancy3, teaching_assistant_vacancy,
            hlta_vacancy, education_support_vacancy, sendco_vacancy,
            administration_hr_data_and_finance_vacancy, it_support_vacancy, pastoral_health_and_welfare_vacancy,
            other_leadership_vacancy, other_support_vacancy, catering_cleaning_and_site_management_vacancy
          )
        end
      end

      context "when organisation_types includes both 'Academy' and 'Local authority maintained schools'" do
        let(:filters) { { organisation_types: ["Academy", "Local authority maintained schools"] } }

        it "will return vacancies associated with local authority maintained schools, academies and free schools" do
          expect(subject)
            .to contain_exactly(
              vacancy1, vacancy2, vacancy3, vacancy5, vacancy6, vacancy7, vacancy8, vacancy9, teaching_assistant_vacancy,
              hlta_vacancy, education_support_vacancy, sendco_vacancy,
              administration_hr_data_and_finance_vacancy, it_support_vacancy, pastoral_health_and_welfare_vacancy,
              other_leadership_vacancy, other_support_vacancy, catering_cleaning_and_site_management_vacancy
            )
        end
      end
    end

    context "when a quick apply filter is selected" do
      let(:filters) { { quick_apply: ["quick_apply"] } }

      it "will return vacancies with TV quick apply status only" do
        expect(subject).to contain_exactly(vacancy1, vacancy2, vacancy3)
      end
    end

    context "when school_types filter is selected" do
      context "when school_types == ['faith_school']" do
        let(:filters) { { school_types: ["faith_school"] } }

        it "will return vacancies associated with faith schools" do
          expect(subject).to contain_exactly(faith_vacancy)
        end
      end

      context "when school_types = ['special_school']" do
        let(:filters) { { school_types: ["special_school"] } }

        it "will return vacancies associated with special schools" do
          expect(subject).to contain_exactly(special_vacancy1, special_vacancy2, special_vacancy3, special_vacancy4, special_vacancy5, special_vacancy6)
        end
      end

      context "when school_types includes 'special_school' and 'faith_school" do
        let(:filters) { { school_types: %w[special_school faith_school] } }

        it "will return vacancies associated with both faith schools and special schools" do
          expect(subject).to contain_exactly(special_vacancy1, special_vacancy2, special_vacancy3, special_vacancy4, special_vacancy5, special_vacancy6, faith_vacancy)
        end
      end
    end

    describe "working patterns search" do
      before do
        create(:vacancy, slug: "pt1", organisations: [free_school], is_job_share: false, working_patterns: %w[part_time])
        create(:vacancy, slug: "ft1", organisations: [free_school], is_job_share: true, working_patterns: %w[full_time])
      end

      context "with job share filter" do
        let(:filters) { { working_patterns: %w[job_share] } }

        it "returns one job" do
          expect(subject.count).to eq(1)
        end
      end

      context "with part time filter" do
        let(:filters) { { working_patterns: %w[part_time] } }

        it "returns pt jobs" do
          expect(subject.map(&:slug)).to contain_exactly("vacancy-1", "pt1")
        end
      end

      context "with part time full time filter" do
        let(:filters) { { working_patterns: %w[part_time full_time] } }

        it "returns many jobs" do
          expect(subject.count).to eq(31)
        end
      end

      context "with full time filter" do
        let(:filters) { { working_patterns: %w[full_time] } }

        it "returns fewer jobs" do
          expect(subject.count).to eq(30)
        end
      end

      context "with part time job share filter" do
        let(:filters) { { working_patterns: %w[part_time job_share] } }

        it "returns two jobs" do
          expect(subject.map(&:slug)).to contain_exactly("vacancy-1", "pt1", "ft1")
        end
      end

      context "with legacy filters" do
        let(:filters) { { working_patterns: %w[compressed_hours staggered_hours] } }

        it "ignores the legacy filters and returns many jobs" do
          expect(subject.count).to eq(31)
        end
      end

      context "with no filters" do
        let(:filters) { { working_patterns: [] } }

        it "ignores the legacy filters and returns many jobs" do
          expect(subject.count).to eq(31)
        end
      end
    end

    describe "phases search" do
      context "with no filters" do
        let(:filters) { { phases: [] } }

        it "returns many jobs" do
          expect(subject.count).to eq(29)
        end
      end

      context "with primary filter" do
        let(:filters) { { phases: %w[primary] } }

        it "returns primary jobs" do
          expect(subject.count).to eq(27)
        end
      end

      context "with primary and secondary filter" do
        let(:filters) { { phases: %w[primary secondary] } }

        it "returns both primary and secondary jobs" do
          expect(subject.count).to eq(28)
        end
      end

      context "with legacy no longer defined filters" do
        let(:filters) { { phases: %w[middle] } }

        it "ignores the legacy filters and returns many jobs" do
          expect(subject.count).to eq(29)
        end
      end

      context "with both legacy and a valid filter" do
        let(:filters) { { phases: %w[middle primary] } }

        it "ignores the legacy filters and applies the filter for the valid value" do
          expect(subject.count).to eq(27)
        end
      end
    end

    describe "roles mapping" do
      context "with leadership" do
        let(:filters) { { teaching_job_roles: %w[leadership] } }

        it "transforms legacy 'leadership' to all senior leadership roles" do
          expect(subject).to contain_exactly(vacancy7, vacancy8, vacancy9)
        end
      end

      context "with senior_leader" do
        let(:filters) { { teaching_job_roles: %w[senior_leader] } }

        it "transforms legacy 'senior_leader' to all senior leadership roles" do
          expect(subject).to contain_exactly(vacancy7, vacancy8, vacancy9)
        end
      end

      context "with middle_leader" do
        let(:filters) { { teaching_job_roles: %w[middle_leader] } }

        it "transforms legacy 'middle_leader' to all middle leadership roles" do
          expect(subject).to contain_exactly(vacancy5, vacancy6)
        end
      end

      context "with invalid role" do
        let(:filters) { { teaching_job_roles: %w[non_valid_role] } }

        it "doesn't filter by role if it is not included in current job roles list" do
          expect(subject).to contain_exactly(
            vacancy1, vacancy2, vacancy3, vacancy4, vacancy5, vacancy6, vacancy7, vacancy8, vacancy9, special_vacancy1,
            special_vacancy2, special_vacancy3, special_vacancy4, special_vacancy5, special_vacancy6, faith_vacancy,
            non_faith_vacancy1, non_faith_vacancy2, non_faith_vacancy3, teaching_assistant_vacancy,
            hlta_vacancy, education_support_vacancy, sendco_vacancy,
            administration_hr_data_and_finance_vacancy, it_support_vacancy, pastoral_health_and_welfare_vacancy,
            other_leadership_vacancy, other_support_vacancy, catering_cleaning_and_site_management_vacancy
          )
        end
      end

      context "with multiple filters" do
        let(:filters) do
          {
            teaching_job_roles: %w[headteacher],
            support_job_roles: %w[other_support higher_level_teaching_assistant],
          }
        end

        it "correctly filters by multiple roles, including all roles selected" do
          expect(subject.count).to eq(3)
          expect(subject).to contain_exactly(vacancy7, other_support_vacancy, hlta_vacancy)
        end
      end

      context "with pastoral" do
        let(:filters) { { support_job_roles: %w[pastoral_health_and_welfare sendco] } }

        it "correctly filters by multiple roles, including all roles selected" do
          expect(subject.count).to eq(3)
          expect(subject).to contain_exactly(pastoral_health_and_welfare_vacancy, sendco_vacancy, vacancy3)
        end
      end

      context "with catering and assistant" do
        let(:filters) { { support_job_roles: %w[teaching_assistant catering_cleaning_and_site_management] } }

        it "correctly filters by multiple roles, including all roles selected" do
          expect(subject.count).to eq(2)
          expect(subject).to contain_exactly(teaching_assistant_vacancy, catering_cleaning_and_site_management_vacancy)
        end
      end

      context "with catering and teacher" do
        let(:filters) do
          {
            teaching_job_roles: %w[teacher],
            support_job_roles: %w[catering_cleaning_and_site_management],
          }
        end

        it "correctly filters by multiple roles, including all roles selected" do
          expect(subject.count).to eq(14)
          expect(subject).to contain_exactly(
            vacancy1, vacancy2, vacancy4, catering_cleaning_and_site_management_vacancy, special_vacancy1,
            special_vacancy2, special_vacancy3, special_vacancy4, special_vacancy5, special_vacancy6, faith_vacancy,
            non_faith_vacancy1, non_faith_vacancy2, non_faith_vacancy3
          )
        end
      end
    end
  end
end
