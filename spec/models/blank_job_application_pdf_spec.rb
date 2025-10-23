require "rails_helper"

RSpec.describe BlankJobApplicationPdf do
  let(:vacancy) do
    build_stubbed(:vacancy, organisations: build_stubbed_list(:school, 1, :catholic),
                            religion_type: :catholic)
  end
  let(:datasource) { described_class.new(job_application) }
  let(:employments) { [] }
  let(:memberships) { [] }
  let(:trainings) { [] }
  let(:quals) { [] }
  let(:refs) { [] }
  let(:job_application) do
    build_stubbed(:job_application, :status_submitted, vacancy: vacancy,
                                                       employments: employments, professional_body_memberships: memberships,
                                                       following_religion: false,
                                                       training_and_cpds: trainings, qualifications: quals, referees: refs)
  end

  describe "#personal_details" do
    subject(:personal_details) { datasource.personal_details }

    let(:scope) { "helpers.label.jobseekers_job_application_personal_details_form" }
    let(:basic_table_data) do
      [
        [I18n.t("first_name", scope:), nil],
        [I18n.t("last_name", scope:), nil],
        [I18n.t("previous_names_optional", scope:), nil],
        [I18n.t("helpers.legend.jobseekers_job_application_personal_details_form.your_address"), nil],
        [I18n.t("phone_number", scope:), nil],
        [I18n.t("email_address", scope:), nil],
        [I18n.t("helpers.legend.jobseekers_job_application_declarations_form.has_right_to_work_in_uk"), nil],
        [I18n.t("working_patterns", scope:), nil],
        [I18n.t("national_insurance_number_review", scope:), nil],
        [I18n.t("working_pattern_details", scope:), nil],
      ]
    end

    it { expect(personal_details).to match_array(basic_table_data) }
  end
end
