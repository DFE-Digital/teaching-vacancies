require "rails_helper"

RSpec.describe VacancyFilterQuery do
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

  let!(:vacancy1) { create(:vacancy, job_title: "Vacancy 1", subjects: %w[English Spanish], working_patterns: %w[full_time], phases: %w[secondary], job_roles: ["teacher"], ect_status: "ect_suitable", organisations: [academy], enable_job_applications: true, visa_sponsorship_available: true) }
  let!(:vacancy2) { create(:vacancy, job_title: "Vacancy 2", subjects: %w[English Spanish], working_patterns: %w[full_time], phases: %w[sixth_form_or_college], job_roles: ["teacher"], ect_status: "ect_unsuitable", organisations: [free_school], enable_job_applications: true) }
  let!(:vacancy3) { create(:vacancy, job_title: "Vacancy 3", subjects: %w[English Spanish], working_patterns: %w[full_time], phases: %w[primary], job_roles: ["sendco"], ect_status: nil, organisations: [local_authority_school], enable_job_applications: true) }
  let!(:vacancy4) { create(:vacancy, :no_tv_applications, job_title: "Vacancy 4", subjects: %w[English Spanish], working_patterns: %w[full_time], phases: %w[primary], job_roles: ["teacher"], ect_status: nil) }
  let!(:vacancy5) { create(:vacancy, :no_tv_applications, job_title: "Vacancy 5", subjects: %w[English Spanish], working_patterns: %w[full_time], phases: %w[primary], job_roles: ["head_of_year_or_phase"], ect_status: nil, organisations: [academies]) }
  let!(:vacancy6) { create(:vacancy, :no_tv_applications, job_title: "Vacancy 6", subjects: %w[English Spanish], working_patterns: %w[full_time], phases: %w[primary], job_roles: ["head_of_department_or_curriculum"], ect_status: nil, publisher_organisation: free_school, organisations: [free_school, free_schools]) }
  let!(:vacancy7) { create(:vacancy, :no_tv_applications, job_title: "Vacancy 7", subjects: %w[English Spanish], working_patterns: %w[full_time], phases: %w[primary], job_roles: ["headteacher"], ect_status: nil, publisher_organisation: free_school, organisations: [free_school, free_schools]) }
  let!(:vacancy8) { create(:vacancy, :no_tv_applications, job_title: "Vacancy 8", subjects: %w[English Spanish], working_patterns: %w[full_time], phases: %w[primary], job_roles: ["assistant_headteacher"], ect_status: nil, publisher_organisation: free_school, organisations: [free_school, free_schools]) }
  let!(:vacancy9) { create(:vacancy, :no_tv_applications, job_title: "Vacancy 9", subjects: %w[English Spanish], working_patterns: %w[full_time], phases: %w[primary], job_roles: ["deputy_headteacher"], ect_status: nil, publisher_organisation: free_school, organisations: [free_school, free_schools]) }
  let!(:teaching_assistant_vacancy) { create(:vacancy, :no_tv_applications, job_title: "Vacancy 10", subjects: %w[], working_patterns: %w[full_time], phases: %w[primary], job_roles: ["teaching_assistant"], ect_status: nil, publisher_organisation: free_school, organisations: [free_school, free_schools]) }
  let!(:hlta_vacancy) { create(:vacancy, :no_tv_applications, job_title: "Vacancy 11", subjects: %w[], working_patterns: %w[full_time], phases: %w[primary], job_roles: ["higher_level_teaching_assistant"], ect_status: nil, publisher_organisation: free_school, organisations: [free_school, free_schools]) }
  let!(:education_support_vacancy) { create(:vacancy, :no_tv_applications, job_title: "Vacancy 12", subjects: %w[], working_patterns: %w[full_time], phases: %w[primary], job_roles: ["education_support"], ect_status: nil, publisher_organisation: free_school, organisations: [free_school, free_schools]) }
  let!(:sendco_vacancy) { create(:vacancy, :no_tv_applications, job_title: "Vacancy 13", subjects: %w[], working_patterns: %w[full_time], phases: %w[primary], job_roles: ["sendco"], ect_status: nil, publisher_organisation: free_school, organisations: [free_school, free_schools]) }
  let!(:administration_hr_data_and_finance_vacancy) { create(:vacancy, :no_tv_applications, job_title: "Vacancy 15", subjects: %w[], working_patterns: %w[full_time], phases: %w[primary], job_roles: ["administration_hr_data_and_finance"], ect_status: nil, publisher_organisation: free_school, organisations: [free_school, free_schools]) }
  let!(:it_support_vacancy) { create(:vacancy, :no_tv_applications, job_title: "Vacancy 16", subjects: %w[], working_patterns: %w[full_time], phases: %w[primary], job_roles: ["it_support"], ect_status: nil, publisher_organisation: free_school, organisations: [free_school, free_schools]) }
  let!(:pastoral_health_and_welfare_vacancy) { create(:vacancy, :no_tv_applications, job_title: "Vacancy 17", subjects: %w[], working_patterns: %w[full_time], phases: %w[primary], job_roles: ["pastoral_health_and_welfare"], ect_status: nil, publisher_organisation: free_school, organisations: [free_school, free_schools]) }
  let!(:other_leadership_vacancy) { create(:vacancy, :no_tv_applications, job_title: "Vacancy 18", subjects: %w[], working_patterns: %w[full_time], phases: %w[primary], job_roles: ["other_leadership"], ect_status: nil, publisher_organisation: free_school, organisations: [free_school, free_schools]) }
  let!(:other_support_vacancy) { create(:vacancy, :no_tv_applications, job_title: "Vacancy 19", subjects: %w[], working_patterns: %w[full_time], phases: %w[primary], job_roles: ["other_support"], ect_status: nil, publisher_organisation: free_school, organisations: [free_school, free_schools]) }
  let!(:catering_cleaning_and_site_management_vacancy) { create(:vacancy, :no_tv_applications, job_title: "Vacancy 19", subjects: %w[], working_patterns: %w[full_time], phases: %w[primary], job_roles: ["catering_cleaning_and_site_management"], ect_status: nil, publisher_organisation: free_school, organisations: [free_school, free_schools]) }

  let!(:special_vacancy1) { create(:vacancy, :no_tv_applications, job_title: "Vacancy 7", subjects: %w[English Spanish], working_patterns: %w[full_time], phases: %w[primary], job_roles: ["teacher"], ect_status: nil, organisations: [special_school1]) }
  let!(:special_vacancy2) { create(:vacancy, :no_tv_applications, job_title: "Vacancy 8", subjects: %w[English Spanish], working_patterns: %w[full_time], phases: %w[primary], job_roles: ["teacher"], ect_status: nil, organisations: [special_school2]) }
  let!(:special_vacancy3) { create(:vacancy, :no_tv_applications, job_title: "Vacancy 9", subjects: %w[English Spanish], working_patterns: %w[full_time], phases: %w[primary], job_roles: ["teacher"], ect_status: nil, organisations: [special_school3]) }
  let!(:special_vacancy4) { create(:vacancy, :no_tv_applications, job_title: "Vacancy 10", subjects: %w[English Spanish], working_patterns: %w[full_time], phases: %w[primary], job_roles: ["teacher"], ect_status: nil, organisations: [special_school4]) }
  let!(:special_vacancy5) { create(:vacancy, :no_tv_applications, job_title: "Vacancy 11", subjects: %w[English Spanish], working_patterns: %w[full_time], phases: %w[primary], job_roles: ["teacher"], ect_status: nil, organisations: [special_school5]) }
  let!(:special_vacancy6) { create(:vacancy, :no_tv_applications, job_title: "Vacancy 12", subjects: %w[English Spanish], working_patterns: %w[full_time], phases: %w[primary], job_roles: ["teacher"], ect_status: nil, organisations: [special_school6]) }
  let!(:faith_vacancy) { create(:vacancy, :no_tv_applications, job_title: "Vacancy 13", subjects: %w[English Spanish], working_patterns: %w[full_time], phases: %w[primary], job_roles: ["teacher"], ect_status: nil, publisher_organisation: faith_school, organisations: [faith_school, faith_school2]) }
  let!(:non_faith_vacancy1) { create(:vacancy, :no_tv_applications, job_title: "Vacancy 14", subjects: %w[English Spanish], working_patterns: %w[full_time], phases: %w[primary], job_roles: ["teacher"], ect_status: nil, organisations: [non_faith_school1]) }
  let!(:non_faith_vacancy2) { create(:vacancy, :no_tv_applications, job_title: "Vacancy 15", subjects: %w[English Spanish], working_patterns: %w[full_time], phases: %w[primary], job_roles: ["teacher"], ect_status: nil, organisations: [non_faith_school2]) }
  let!(:non_faith_vacancy3) { create(:vacancy, :no_tv_applications, job_title: "Vacancy 14", subjects: %w[English Spanish], working_patterns: %w[full_time], phases: %w[primary], job_roles: ["teacher"], ect_status: nil, organisations: [non_faith_school3], visa_sponsorship_available: true) }

  describe "#call" do
    it "queries based on the given filters" do
      filters = {
        subjects: %w[English Spanish],
        working_patterns: %w[full_time],
        phases: %w[secondary],
        teaching_job_roles: %w[teacher],
        ect_statuses: %w[ect_suitable],
        from_date: 5.days.ago,
        to_date: Date.today,
      }
      expect(subject.call(filters)).to contain_exactly(vacancy1)
    end

    context "when visa_sponsorship_available is selected" do
      it "will return vacancies that offer visa sponsorships" do
        filters = {
          visa_sponsorship_availability: ["true"],
        }

        expect(subject.call(filters)).to contain_exactly(vacancy1, non_faith_vacancy3)
      end
    end

    context "when organisation_types filter is selected" do
      context "when organisation_types == ['Academy']" do
        it "will return vacancies associated with academies and free schools" do
          filters = {
            organisation_types: ["Academy"],
          }
          expect(subject.call(filters))
            .to contain_exactly(vacancy1, vacancy2, vacancy5, vacancy6, vacancy7, vacancy8, vacancy9, teaching_assistant_vacancy,
                                hlta_vacancy, education_support_vacancy, sendco_vacancy,
                                administration_hr_data_and_finance_vacancy, it_support_vacancy, pastoral_health_and_welfare_vacancy,
                                other_leadership_vacancy, other_support_vacancy, catering_cleaning_and_site_management_vacancy)
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
          expect(subject.call(filters)).to contain_exactly(
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
        it "will return vacancies associated with local authority maintained schools, academies and free schools" do
          filters = {
            organisation_types: ["Academy", "Local authority maintained schools"],
          }
          expect(subject.call(filters))
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
      it "will return vacancies with TV quick apply status only" do
        filters = {
          quick_apply: ["quick_apply"],
        }
        expect(subject.call(filters)).to contain_exactly(vacancy1, vacancy2, vacancy3)
      end
    end

    context "when school_types filter is selected" do
      context "when school_types == ['faith_school']" do
        it "will return vacancies associated with faith schools" do
          filters = {
            school_types: ["faith_school"],
          }
          expect(subject.call(filters)).to contain_exactly(faith_vacancy)
        end
      end

      context "when school_types = ['special_school']" do
        it "will return vacancies associated with special schools" do
          filters = {
            school_types: ["special_school"],
          }
          expect(subject.call(filters)).to contain_exactly(special_vacancy1, special_vacancy2, special_vacancy3, special_vacancy4, special_vacancy5, special_vacancy6)
        end
      end

      context "when school_types includes 'special_school' and 'faith_school" do
        it "will return vacancies associated with both faith schools and special schools" do
          filters = {
            school_types: %w[special_school faith_school],
          }
          expect(subject.call(filters)).to contain_exactly(special_vacancy1, special_vacancy2, special_vacancy3, special_vacancy4, special_vacancy5, special_vacancy6, faith_vacancy)
        end
      end
    end

    context "when working_patterns filter is selected" do
      context "when job_share is selected" do
        it "will return vacancies where is_job_share is true" do
          filters = {
            working_patterns: %w[job_share],
          }

          expect(subject.call(filters).map(&:is_job_share).uniq).to contain_exactly(true)
        end
      end
    end

    it "transforms legacy phases filters to new ones" do
      filters = {
        phases: %w[16-19],
      }
      expect(subject.call(filters)).to contain_exactly(vacancy2)
    end

    describe "roles mapping" do
      it "transforms legacy 'leadership' to all senior leadership roles" do
        filters = {
          teaching_job_roles: %w[leadership],
        }
        expect(subject.call(filters)).to contain_exactly(vacancy7, vacancy8, vacancy9)
      end

      it "transforms legacy 'senior_leader' to all senior leadership roles" do
        filters = {
          teaching_job_roles: %w[senior_leader],
        }
        expect(subject.call(filters)).to contain_exactly(vacancy7, vacancy8, vacancy9)
      end

      it "transforms legacy 'middle_leader' to all middle leadership roles" do
        filters = {
          teaching_job_roles: %w[middle_leader],
        }
        expect(subject.call(filters)).to contain_exactly(vacancy5, vacancy6)
      end

      it "doesn't filter by role if it is not included in current job roles list" do
        filters = {
          teaching_job_roles: %w[non_valid_role],
        }
        expect(subject.call(filters)).to contain_exactly(
          vacancy1, vacancy2, vacancy3, vacancy4, vacancy5, vacancy6, vacancy7, vacancy8, vacancy9, special_vacancy1,
          special_vacancy2, special_vacancy3, special_vacancy4, special_vacancy5, special_vacancy6, faith_vacancy,
          non_faith_vacancy1, non_faith_vacancy2, non_faith_vacancy3, teaching_assistant_vacancy,
          hlta_vacancy, education_support_vacancy, sendco_vacancy,
          administration_hr_data_and_finance_vacancy, it_support_vacancy, pastoral_health_and_welfare_vacancy,
          other_leadership_vacancy, other_support_vacancy, catering_cleaning_and_site_management_vacancy
        )
      end

      it "correctly filters by multiple roles, including all roles selected" do
        filters = {
          teaching_job_roles: %w[headteacher],
          support_job_roles: %w[other_support higher_level_teaching_assistant],
        }
        expect(subject.call(filters).count).to eq(3)
        expect(subject.call(filters)).to contain_exactly(vacancy7, other_support_vacancy, hlta_vacancy)

        filters = {
          support_job_roles: %w[pastoral_health_and_welfare sendco],
        }
        expect(subject.call(filters).count).to eq(3)
        expect(subject.call(filters)).to contain_exactly(pastoral_health_and_welfare_vacancy, sendco_vacancy, vacancy3)

        filters = {
          support_job_roles: %w[teaching_assistant catering_cleaning_and_site_management],
        }
        expect(subject.call(filters).count).to eq(2)
        expect(subject.call(filters)).to contain_exactly(teaching_assistant_vacancy, catering_cleaning_and_site_management_vacancy)

        filters = {
          teaching_job_roles: %w[teacher],
          support_job_roles: %w[catering_cleaning_and_site_management],
        }
        expect(subject.call(filters).count).to eq(14)
        expect(subject.call(filters)).to contain_exactly(
          vacancy1, vacancy2, vacancy4, catering_cleaning_and_site_management_vacancy, special_vacancy1,
          special_vacancy2, special_vacancy3, special_vacancy4, special_vacancy5, special_vacancy6, faith_vacancy,
          non_faith_vacancy1, non_faith_vacancy2, non_faith_vacancy3
        )
      end
    end
  end
end
