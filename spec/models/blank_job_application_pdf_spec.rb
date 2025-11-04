require "rails_helper"

RSpec.describe BlankJobApplicationPdf do
  let(:vacancy) do
    build_stubbed(:vacancy, organisations: build_stubbed_list(:school, 1, :catholic), religion_type:)
  end
  let(:religion_type) { "catholic" }
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

  describe "#religious_information" do
    subject(:religious_information) { datasource.religious_information }

    context "when catholic" do
      let(:religion_type) { "catholic" }
      let(:religious_data) do
        [
          ["Are you currently following a religion or faith?", "Yes / No"],
          ["What is your religious denomination or faith?", nil],
          ["Address of place of worship (optional)", nil],
          ["Can you provide a religious referee?", "Yes / No"],
          ["If yes, please provide the below information for your religious referee", nil],
          ["Name", nil],
          ["Address", nil],
          ["Role", nil],
          ["Email", nil],
          ["Phone number (optional)", nil],
          ["if you cannot provide a religious referee, can you provide a baptism certificate?", "If yes, please enclose a copy of your certificate."],
          ["If you cannot provide a religious referee or a baptism certificate, con you provide the date and address of your baptism?", "Yes / No / Not applicable"],
          ["if yes, please provide the below information", nil],
          ["Address of baptism location", nil],
          ["Date of your baptism", nil],
          ["Please tick here if you cannot provide a religious referee, a baptism certificate or the date and address of your baptism.", nil],
        ]
      end

      it { expect(religious_information).to match_array(religious_data) }
    end

    context "when other religion" do
      let(:religion_type) { "other_religion" }
      let(:religious_data) do
        [
          ["How will you support the school's ethos and aims", nil],
          ["Are you currently following a religion or faith?", "Yes / No"],
          ["What is your religious denomination or faith?", nil],
          ["Address of place of worship (optional)", nil],
          ["Can you provide religious referee?", "Yes / No"],
          ["If yes, please provide the below information for your religious referee", nil],
          ["Name", nil],
          ["Address", nil],
          ["Roles", nil],
          ["Email", nil],
          ["Phone number (optional)", nil],
        ]
      end

      it { expect(religious_information).to match_array(religious_data) }
    end
  end
end
