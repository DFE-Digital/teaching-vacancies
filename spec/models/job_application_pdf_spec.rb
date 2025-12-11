require "rails_helper"

RSpec.describe JobApplicationPdf do
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

  context "without religious information" do
    let(:job_application) do
      build_stubbed(:job_application, :status_submitted, vacancy: vacancy,
                                                         employments: employments, professional_body_memberships: memberships,
                                                         following_religion: false,
                                                         training_and_cpds: trainings, qualifications: quals, referees: refs)
    end

    describe "#header_text" do
      subject(:header_text) { datasource.header_text }

      let(:expected_header) do
        I18n.t(
          "jobseekers.job_applications.caption",
          job_title: vacancy.job_title,
          organisation: vacancy.organisation_name,
        )
      end

      it { is_expected.to eq(expected_header) }
    end

    describe "#applicant_name" do
      subject(:applicant_name) { datasource.applicant_name }

      it { is_expected.to eq(job_application.name) }
    end

    describe "#footer_text" do
      subject(:footer_text) { datasource.footer_text }

      let(:expected_text) { "#{job_application.name} | #{vacancy.organisation_name}" }

      it { is_expected.to eq(expected_text) }
    end

    describe "#personal_details" do
      subject(:personal_details) { datasource.personal_details }

      before do
        job_application.working_pattern_details = nil
        job_application.national_insurance_number = nil
      end

      let(:scope) { "helpers.label.jobseekers_job_application_personal_details_form" }
      let(:address) do
        [
          job_application.street_address,
          job_application.city,
          job_application.postcode,
          job_application.country,
        ].compact.join(", ")
      end
      let(:basic_table_data) do
        [
          [I18n.t("first_name", scope:), job_application.first_name],
          [I18n.t("last_name", scope:), job_application.last_name],
          [I18n.t("previous_names_optional", scope:), job_application.previous_names],
          [I18n.t("helpers.legend.jobseekers_job_application_personal_details_form.your_address"), address],
          [I18n.t("phone_number", scope:), job_application.phone_number],
          [I18n.t("email_address", scope:), job_application.email_address],
          [I18n.t("helpers.legend.jobseekers_job_application_declarations_form.has_right_to_work_in_uk"), "No, I already have the right to work in the UK"],
          [I18n.t("working_patterns", scope:), "Part time"],
        ]
      end

      it { is_expected.to be_a(JobApplicationPdf::Table) }
      it { expect(personal_details).to match_array(basic_table_data) }

      context "when working pattern details present" do
        let(:details) { "some details" }
        let(:expected_row) { [I18n.t("working_pattern_details", scope:), details] }

        before { job_application.working_pattern_details = details }

        it { expect(personal_details).to include(expected_row) }
      end

      context "when ni number present" do
        let(:ni_number) { "QQ 12 34 56 C" }
        let(:expected_row) { [I18n.t("national_insurance_number_review", scope:), ni_number] }

        before { job_application.national_insurance_number = ni_number }

        it { expect(personal_details).to include(expected_row) }
      end
    end

    describe "#personal_statement" do
      subject(:personal_statement) { datasource.personal_statement }

      context "when present" do
        let(:statement) { "My personal statement" }

        before { job_application.personal_statement_richtext = statement }

        it { is_expected.to eq(statement) }
      end

      context "when blank" do
        before do
          job_application.personal_statement_richtext = nil
        end

        it { is_expected.to eq(I18n.t("jobseekers.job_applications.review.personal_statement.blank")) }
      end

      context "with rich text formatting" do
        context "when text contains line breaks, bold and italics" do
          let(:html) do
            '<div class="trix-content"><div><strong>bold text<br>next line</strong><br><em>italic only</em><br><strong><em>bold and italic</em></strong></div></div>'
          end

          before { job_application.personal_statement_richtext = html }

          it "preserves line breaks and all formatting types" do
            expect(personal_statement).to eq("<b>bold text\nnext line</b>\n<i>italic only</i>\n<b><i>bold and italic</i></b>")
          end
        end

        context "when text contains bullet points" do
          let(:html) do
            '<div class="trix-content"><ul><li>first item</li><li>second item</li></ul></div>'
          end

          before { job_application.personal_statement_richtext = html }

          it "formats bullets with bullet character" do
            expect(personal_statement).to eq("• first item\n• second item")
          end
        end

        context "when text contains unhandled HTML tags" do
          let(:html) do
            '<div class="trix-content"><div><span>text in span</span></div></div>'
          end

          before { job_application.personal_statement_richtext = html }

          it "strips unhandled tags but keeps content" do
            expect(personal_statement).to eq("text in span")
          end
        end
      end

      context "when text contains HTML comments" do
        let(:html) do
          '<div class="trix-content"><div>text before<!-- comment -->text after</div></div>'
        end

        before { job_application.personal_statement_richtext = html }

        it "strips comments from output" do
          expect(personal_statement).to eq("text beforetext after")
        end
      end

      describe "#process_node" do
        it "returns empty string when node is nil" do
          expect(datasource.send(:process_node, nil)).to eq("")
        end
      end
    end

    describe "#professional_status" do
      subject(:professional_status) { datasource.professional_status }

      let(:scope) { "helpers.legend.jobseekers_job_application_professional_status_form" }
      let(:label_scope) { "helpers.label.jobseekers_job_application_personal_details_form" }
      let(:basic_professional_status_data) do
        [
          [I18n.t("qualified_teacher_status", scope:), "Yes, gained in #{job_application.qualified_teacher_status_year}"],
          [I18n.t("jobseekers.job_application.age_range_and_subject"), "not provided"],
          [I18n.t("teacher_reference_number_review", scope: label_scope), job_application.teacher_reference_number],
          [I18n.t("is_statutory_induction_complete", scope:), "Yes"],
        ]
      end

      it { is_expected.to be_a(JobApplicationPdf::Table) }
      it { expect(professional_status).to match_array(basic_professional_status_data) }

      context "when statutory induction complete details present" do
        let(:details) { "Details about induction completion" }
        let(:expected_row) { [I18n.t("statutory_induction_complete_details", scope:), details] }

        before do
          job_application.is_statutory_induction_complete = true
          job_application.statutory_induction_complete_details = details
        end

        it { expect(professional_status).to include(expected_row) }
      end

      context "when qualified teacher status is yes" do
        before do
          job_application.qualified_teacher_status = "yes"
          job_application.qualified_teacher_status_year = "2020"
        end

        it "includes the proper status info" do
          expected_row = [
            [I18n.t("qualified_teacher_status", scope:), "Yes, gained in 2020"],
            [I18n.t("jobseekers.job_application.age_range_and_subject"), "not provided"],
            [I18n.t("helpers.label.jobseekers_job_application_personal_details_form.teacher_reference_number_review"), job_application.teacher_reference_number],
            [I18n.t("is_statutory_induction_complete", scope:), "Yes"],
          ]
          expect(professional_status).to match_array(expected_row)
        end
      end

      context "when qualified teacher status is no" do
        let(:details) { "Details about not having qualified teacher status" }

        before do
          job_application.qualified_teacher_status = "no"
          job_application.qualified_teacher_status_details = details
        end

        it "includes the proper status info" do
          expected_row = [I18n.t("qualified_teacher_status", scope:), "No. #{details}"]
          expect(professional_status).to include(expected_row)
        end
      end

      context "when qualified teacher status is on track" do
        before do
          job_application.qualified_teacher_status = "on_track"
        end

        it "includes the proper status info" do
          expected_row = [I18n.t("qualified_teacher_status", scope:), "I'm on track to receive my QTS"]
          expect(professional_status).to include(expected_row)
        end
      end
    end

    describe "#qualifications" do
      subject(:qualifications) { datasource.qualifications }

      context "when no qualifications present" do
        it "returns no data available message" do
          expect(qualifications).to eq([[I18n.t("jobseekers.job_applications.show.qualifications.none"), nil]])
        end
      end

      context "when qualifications present" do
        let(:quals) { build_stubbed_list(:qualification, 1, category: "undergraduate") }

        it "returns qualification data" do
          expect(qualifications.first.first).to eq(I18n.t("helpers.label.jobseekers_qualifications_category_form.category_options.undergraduate"))
        end
      end

      context "when secondary qualifications present" do
        let(:quals) { build_stubbed_list(:qualification, 1, category: "gcse", qualification_results: [result]) }
        let(:result) { build_stubbed(:qualification_result) }

        it "formats secondary qualifications correctly" do
          expect(qualifications.first.last.first.first).to include("Secondary Qualification")
          expect(qualifications.first.last.first).to include(["Subject:", result.subject])
        end
      end

      context "when general qualification present" do
        let(:qualification) do
          build_stubbed(:qualification, category: "undergraduate",
                                        qualification_results: build_stubbed_list(:qualification_result, 1))
        end
        let(:quals) { [qualification] }

        it "formats secondary qualifications correctly" do
          expect(qualifications.first.last.first.first).to include("Undergraduate degree")
          expect(qualifications.first.last.first).to include(["Institution:", qualification.institution])
        end
      end
    end

    describe "#training_and_cpds" do
      subject(:training_and_cpds) { datasource.training_and_cpds }

      context "when no training and CPDs present" do
        it "returns no data available message" do
          expect(training_and_cpds).to eq([[I18n.t("jobseekers.job_applications.show.training_and_cpds.none"), nil]])
        end
      end

      context "when training and CPDs present" do
        let(:trainings) { build_stubbed_list(:training_and_cpd, 1, name: "First Aid", year_awarded: "2020", provider: nil, grade: nil, course_length: nil) }

        it "returns training data" do
          expected_table = [
            ["Name", "First Aid"],
            ["Awarded Year", "2020"],
          ]
          expect(training_and_cpds.first.last.first).to match_array(expected_table)
        end
      end

      context "when training with grade present" do
        let(:trainings) { build_stubbed_list(:training_and_cpd, 1, name: "Advanced Course", year_awarded: "2020", provider: nil, grade: "Distinction", course_length: nil) }

        it "includes grade information" do
          expected_table = [
            ["Name", "Advanced Course"],
            ["Grade", "Distinction"],
            ["Awarded Year", "2020"],
          ]
          expect(training_and_cpds.first.last.first).to match_array(expected_table)
        end
      end

      context "when training with provider present" do
        let(:trainings) { build_stubbed_list(:training_and_cpd, 1, name: "First Aid", year_awarded: "2020", provider: "Red cross", grade: nil, course_length: "") }

        it "includes grade information" do
          expected_table = [
            ["Name", "First Aid"],
            ["Provider", "Red cross"],
            ["Awarded Year", "2020"],
          ]
          expect(training_and_cpds.first.last.first).to match_array(expected_table)
        end
      end

      context "when training with course length present" do
        let(:trainings) { build_stubbed_list(:training_and_cpd, 1, name: "Advanced Course", year_awarded: "2020", provider: nil, grade: " ", course_length: "6 months") }

        it "includes grade information" do
          expected_table = [
            ["Name", "Advanced Course"],
            ["Course length", "6 months"],
            ["Awarded Year", "2020"],
          ]
          expect(training_and_cpds.first.last.first).to match_array(expected_table)
        end
      end
    end

    describe "#professional_body_memberships" do
      subject(:professional_body_memberships) { datasource.professional_body_memberships }

      context "when no professional body memberships present" do
        it "returns no data available message" do
          expect(professional_body_memberships).to eq([[I18n.t("jobseekers.job_applications.review.professional_body_memberships.none"), nil]])
        end
      end

      context "when professional body memberships present" do
        let(:memberships) { build_stubbed_list(:professional_body_membership, 1, name: "Royal Society of Chemistry") }

        it "returns membership data" do
          expect(professional_body_memberships.first.last.first).to include(["Name of professional body:", "Royal Society of Chemistry"])
        end
      end
    end

    describe "#employment_history" do
      subject(:employment_history) { datasource.employment_history }

      let(:employment_data) { employment_history.first.last.first }

      context "when no employments present" do
        it "returns no data available message" do
          expect(employment_history).to eq([[I18n.t("jobseekers.job_applications.show.employment_history.none"), nil]])
        end
      end

      context "when employment entries present" do
        let(:employment) { build_stubbed(:employment, ended_on: Time.zone.today) }
        let(:employments) { [employment] }

        it "returns employment data" do
          expect(employment_data).to include(%w[Employment])
          expect(employment_data).to include(["Job Title:", employment.job_title])
          expect(employment_data).to include(["End date:", employment.ended_on.to_fs(:month_year)])
        end
      end

      context "when employment break present" do
        let(:reason_for_break) { Faker::Adjective.negative }
        let(:employments) { build_stubbed_list(:employment, 1, :break, reason_for_break: reason_for_break) }

        it "formats employment break correctly" do
          expect(employment_data).to include(["Employment Break"])
          expect(employment_data).to include(["Reason:", reason_for_break])
          expect(employment_data).to include(["End date:", "present"])
        end
      end

      context "when employment has unexplained gap" do
        let(:employment) { build_stubbed(:employment) }
        let(:employments) { [employment] }
        let(:gap) { { started_on: 1.year.ago.to_date, ended_on: Time.zone.today } }

        before do
          allow(job_application).to receive(:unexplained_employment_gaps).and_return(employment => gap)
        end

        it "includes the unexplained gap" do
          first_table = employment_history.first.last.first
          expect(first_table).to include(["Unexplained Employment Gap"])
          expect(employment_data).to include(["End date:", "present"])
        end
      end
    end

    describe "#references" do
      subject(:referees) { datasource.referees }

      context "when no references present" do
        it "returns no data available message" do
          expect(referees).to eq([[I18n.t("jobseekers.job_applications.show.employment_history.none"), nil]])
        end
      end

      context "when references present" do
        let(:referee) { build_stubbed(:referee) }
        let(:refs) { [referee] }

        it "returns reference data" do
          expect(referees.first.last.first).to include(["Name:", referee.name])
          expect(referees.first.last.first).to include(["Organisation:", referee.organisation])
        end
      end

      context "when jobseeker want to be notified before contacting the referer" do
        let(:referee) { build_stubbed(:referee) }
        let(:refs) { [referee] }

        before { job_application.notify_before_contact_referers = true }

        it "adds a notification request statement" do
          expect(referees.first.first).to eq(I18n.t("jobseekers.job_applications.review.contact_referer.publisher"))
        end
      end

      context "when reference has phone number" do
        let(:referee) { build_stubbed(:referee, phone_number: "01234567890") }
        let(:refs) { [referee] }

        it "includes phone number" do
          expect(referees.first.last.first).to include(["Phone Number:", "01234567890"])
        end
      end

      context "when is_most_recent_employer is set" do
        let(:referee) { build_stubbed(:referee, is_most_recent_employer: true) }
        let(:refs) { [referee] }

        it "includes most recent employer information" do
          expect(referees.first.last.first).to include(["Current or most recent employer:", "Yes"])
        end
      end
    end

    describe "#ask_for_support" do
      subject(:ask_for_support) { datasource.ask_for_support }

      it { is_expected.to be_a(JobApplicationPdf::Table) }

      context "when no support needed" do
        before { job_application.is_support_needed = false }

        it "shows 'No' for support needed" do
          expected_row = [
            I18n.t("helpers.legend.jobseekers_job_application_ask_for_support_form.is_support_needed"),
            "No",
          ]
          expect(ask_for_support).to include(expected_row)
        end
      end

      context "when support needed with details" do
        let(:details) { "I need specific accommodations" }

        before do
          job_application.is_support_needed = true
          job_application.support_needed_details = details
        end

        it "shows 'Yes' with details for support needed" do
          expected_row = [
            I18n.t("helpers.legend.jobseekers_job_application_ask_for_support_form.is_support_needed"),
            "Yes\nDetails: #{details}",
          ]
          expect(ask_for_support).to include(expected_row)
        end
      end
    end

    describe "#declarations" do
      subject(:declarations) { datasource.declarations }

      it { is_expected.to be_a(JobApplicationPdf::Table) }

      context "when no safeguarding issues or close relationships" do
        before do
          job_application.has_safeguarding_issue = false
          job_application.has_close_relationships = false
        end

        it "shows 'No' for both declarations" do
          scope = "helpers.legend.jobseekers_job_application_declarations_form"
          expected_data = [
            [I18n.t("has_safeguarding_issue", scope:), "No"],
            [I18n.t("has_close_relationships.other", scope:, organisation: vacancy.organisation_name), "No"],
          ]
          expect(declarations).to eq(expected_data)
        end
      end

      context "when has safeguarding issues with details" do
        let(:details) { "Details about safeguarding issues" }

        before do
          job_application.has_safeguarding_issue = true
          job_application.safeguarding_issue_details = details
        end

        it "shows 'Yes' with details for safeguarding issues" do
          scope = "helpers.legend.jobseekers_job_application_declarations_form"
          expected_row = [I18n.t("has_safeguarding_issue", scope:), "Yes\nDetails: #{details}"]
          expect(declarations).to include(expected_row)
        end
      end

      context "when has close relationships with details" do
        let(:details) { "Details about close relationships" }

        before do
          job_application.has_close_relationships = true
          job_application.close_relationships_details = details
        end

        it "shows 'Yes' with details for close relationships" do
          scope = "helpers.legend.jobseekers_job_application_declarations_form"
          expected_row = [I18n.t("has_close_relationships.other", scope:, organisation: vacancy.organisation_name), "Yes\nDetails: #{details}"]
          expect(declarations).to include(expected_row)
        end
      end
    end
  end

  describe "#religious_application?" do
    subject(:religious_application) { datasource.religious_application? }

    let(:job_application) { build_stubbed(:job_application, vacancy: vacancy) }

    context "when vacancy has no religion type" do
      let(:vacancy) { build_stubbed(:vacancy, religion_type: nil) }

      it { is_expected.to be false }
    end

    context "when vacancy religion type is no_religion" do
      let(:vacancy) { build_stubbed(:vacancy, religion_type: "no_religion") }

      it { is_expected.to be false }
    end

    context "when vacancy religion type is catholic" do
      let(:vacancy) { build_stubbed(:vacancy, religion_type: "catholic") }

      it { is_expected.to be true }
    end

    context "when vacancy religion type is other_religion" do
      let(:vacancy) { build_stubbed(:vacancy, religion_type: "other_religion") }

      it { is_expected.to be true }
    end
  end

  describe "religious applications" do
    context "with a baptism cerificate" do
      let(:job_application) do
        build_stubbed(:job_application, :status_submitted, :with_baptism_certificate, vacancy: vacancy,
                                                                                      employments: employments, professional_body_memberships: memberships,
                                                                                      training_and_cpds: trainings, qualifications: quals, referees: refs)
      end

      it "contains the filename" do
        expect(datasource.religious_information)
          .to include([I18n.t("jobseekers.job_applications.review.religious_information.baptism_certificate"), job_application.baptism_certificate.filename])
      end
    end

    context "without a religious reference" do
      let(:job_application) do
        build_stubbed(:job_application, :status_submitted, following_religion: true, religious_reference_type: nil, vacancy: vacancy,
                                                           employments: employments, professional_body_memberships: memberships,
                                                           training_and_cpds: trainings, qualifications: quals, referees: refs)
      end

      it "produces data" do
        expect(datasource.religious_information).not_to be_empty
      end
    end

    context "when not following a religion" do
      let(:job_application) do
        build_stubbed(:job_application, :status_submitted, following_religion: false, vacancy: vacancy,
                                                           employments: employments, professional_body_memberships: memberships,
                                                           training_and_cpds: trainings, qualifications: quals, referees: refs)
      end

      it "produces some lines" do
        expect(datasource.religious_information).not_to be_empty
      end
    end
  end
end
