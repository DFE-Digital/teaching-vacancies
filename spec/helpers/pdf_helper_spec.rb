require "rails_helper"
require "prawn"
require "pdf/inspector"

RSpec.describe JobApplicationPdfGenerator, type: :service do
  let(:job_application) { create(:job_application, create_details: false, vacancy: vacancy, working_patterns: %w[full_time part_time]) }
  let!(:professional_body_membership) { create(:professional_body_membership, job_application: job_application, membership_number: nil, year_membership_obtained: nil) }
  let(:vacancy) { create(:vacancy) }
  let(:pdf_generator) { JobApplicationPdfGenerator.new(job_application, vacancy) }

  describe "#generate" do
    let(:pdf) { pdf_generator.generate.render }
    let(:text_analysis) { PDF::Inspector::Text.analyze(pdf) }

    it "generates a valid PDF document" do
      expect(pdf).to be_a(String)
    end

    it "renders the PDF without errors" do
      expect { pdf_generator.generate.render }.not_to raise_error
    end

    it "includes the applicant’s name" do
      expect(text_analysis.strings).to include(job_application.first_name)
    end

    it "includes applicants working pattern preferences" do
      expect(text_analysis.strings).to include("Full time, part time")
      expect(text_analysis.strings).to include(job_application.working_pattern_details)
    end

    it "includes the job title and organization" do
      header = I18n.t("jobseekers.job_applications.caption", job_title: vacancy.job_title, organisation: vacancy.organisation_name)
      expect(text_analysis.strings).to include(header)
    end

    it "includes section titles" do
      expect(text_analysis.strings).to include("Personal Details")
      expect(text_analysis.strings).to include("Professional Status")
      expect(text_analysis.strings).to include("Qualifications")
      expect(text_analysis.strings).to include("Training and CPD")
      expect(text_analysis.strings).to include("Professional body memberships")
      expect(text_analysis.strings).to include("Employment History")
      expect(text_analysis.strings).to include("Personal Statement")
      expect(text_analysis.strings).to include("References")
      expect(text_analysis.strings).to include("Ask for Support")
      expect(text_analysis.strings).to include("Declarations")
    end

    it "includes the applicant's personal details" do
      expect(text_analysis.strings).to include(job_application.first_name)
      expect(text_analysis.strings).to include(job_application.last_name)
      expect(text_analysis.strings).to include(job_application.email_address)
      expect(text_analysis.strings).to include(job_application.phone_number)
      expect(text_analysis.strings).to include(job_application.national_insurance_number)
    end

    context "with employments" do
      before do
        # turns out subjects column can't be nil (but can be blank)
        create(:employment, job_title: employment_no_subjects, job_application: job_application, subjects: "")
        create(:employment, :current_role, job_title: employment_with_subjects, job_application: job_application)
      end

      let(:employment_no_subjects) { Faker::Job.title }
      let(:employment_with_subjects) { Faker::Job.title }

      it "renders both employments" do
        expect(text_analysis.strings).to include(employment_no_subjects)
        expect(text_analysis.strings).to include(employment_with_subjects)
      end
    end

    context "when rendering professional body memberships" do
      context "when professional body memberships exist" do
        let(:pdf_data) { text_analysis.strings.join(" ") }

        it "includes applicant's professional body membership data" do
          expect(pdf_data).to include("Name of professional body:")
          expect(pdf_data).to include(professional_body_membership.name)
          expect(pdf_data).to include("Membership type or level:")
          expect(pdf_data).to include(professional_body_membership.membership_type)
        end

        it "does not show blank lines where optional professional body membership data does not exist" do
          expect(pdf_data).not_to include("Membership number or registration")
          expect(pdf_data).not_to include("Date obtained")
        end
      end

      context "when there are no professional body memberships" do
        let(:job_application_without_memberships) { create(:job_application, vacancy: vacancy) }
        let(:pdf_generator) { JobApplicationPdfGenerator.new(job_application_without_memberships, vacancy) }
        let(:pdf_data) { text_analysis.strings.join(" ") }

        it "displays the none message" do
          expect(pdf_data).to include(I18n.t("jobseekers.job_applications.show.professional_body_memberships.none"))
        end
      end
    end

    context "when working_pattern_details is not present" do
      let(:job_application_without_working_pattern_details) { create(:job_application, vacancy: vacancy, working_pattern_details: nil) }
      let(:pdf_generator) { JobApplicationPdfGenerator.new(job_application_without_working_pattern_details, vacancy) }

      it "does not show working pattern details" do
        expect(text_analysis.strings).not_to include("orking pattern preference details")
      end
    end

    context "when national insurance number is not present" do
      let(:job_application_without_ni_number) { create(:job_application, vacancy: vacancy, national_insurance_number: nil) }
      let(:pdf_generator) { JobApplicationPdfGenerator.new(job_application_without_ni_number, vacancy) }

      it "does not show national insurance number" do
        expect(text_analysis.strings).not_to include("National Insurance number")
      end
    end
  end
end
