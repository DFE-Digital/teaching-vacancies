require "rails_helper"

RSpec.describe CandidatesTableComponent, type: :component do
  include Rails.application.routes.url_helpers

  let(:vacancy) { build_stubbed(:vacancy) }
  let(:status) { :status_submitted }
  let(:alice) { build_stubbed(:job_application, status, first_name: "Alice", last_name: "Archer", vacancy:).decorate }
  let(:candidates) { [alice] }
  let(:component) { described_class.new(vacancy:, candidates:) }

  # Assertions use `page`: Capybara can't find fields by label in what render_inline returns
  before { render_inline(component) }

  it "shows name, contact details and status by default" do
    expect(page).to have_table(with_rows: [{ "Name" => "Alice Archer", "Contact details" => alice.email_address, "Application status" => "unread" }], exact: true)
  end

  describe "Name" do
    let(:application_path) { organisation_job_job_application_path(vacancy.id, alice) }

    it "links to the application" do
      expect(page).to have_link("Alice Archer", href: application_path)
    end

    context "with a withdrawn candidate" do
      let(:status) { :status_withdrawn }

      it "shows the name without a link" do
        expect(page).to have_table(with_rows: [{ "Name" => "Alice Archer" }], exact: true)
        expect(page).to have_no_link("Alice Archer")
      end
    end

    context "when the vacancy anonymises applications" do
      let(:vacancy) { build_stubbed(:vacancy, anonymise_applications: true) }
      # Derived from the application's id, so it differs each run
      let(:reference) { alice.anonymised_name }

      it "shows only the anonymised reference, linked to the application" do
        expect(page).to have_table(with_rows: [{ "Name" => reference, "Contact details" => "Information not shown" }], exact: true)
        expect(page).to have_link(reference, href: application_path)
      end

      context "with personal details visible" do
        let(:status) { :status_shortlisted }

        it "links the name and shows the anonymised reference underneath" do
          expect(page).to have_link("Alice Archer", href: application_path)
          expect(page).to have_text(reference)
        end
      end
    end
  end

  describe "Application status" do
    context "with an offered candidate" do
      let(:status) { :status_offered }

      it "links to pre-employment checks" do
        expect(page).to have_table(with_rows: [{ "Application status" => "job offered" }])
        expect(page).to have_link("Pre-employment checks", href: pre_employment_checks_organisation_job_job_application_path(vacancy.id, alice.id))
      end
    end

    context "with an interviewing candidate" do
      let(:status) { :status_interviewing }

      it "links to pre-interview checks" do
        expect(page).to have_table(with_rows: [{ "Application status" => "interviewing" }])
        expect(page).to have_link("Pre-interview checks", href: pre_interview_checks_organisation_job_job_application_path(vacancy.id, alice.id))
      end
    end
  end

  describe "date columns" do
    let(:alice) do
      build_stubbed(:job_application, :status_offered, first_name: "Alice", last_name: "Archer", vacancy:,
                                                       offered_at: date, declined_at: date, interview_feedback_received_at: date, interviewing_at: date).decorate
    end
    let(:component) do
      described_class.new(vacancy:, candidates:,
                          displayed_fields: %i[name offered_at declined_at interview_feedback_received_at interviewing_at])
    end

    def add_date_path(origin, tag_action)
      tag_organisation_job_job_applications_path(vacancy.id, params: { publishers_job_application_tag_form: { origin:, job_applications: [alice.id] }, tag_action: })
    end

    context "when the dates are set" do
      let(:date) { Time.zone.local(2025, 3, 14, 14, 30) }

      it "shows them, with the time for interviews" do
        expect(page).to have_table(with_rows: [{
          "Offer date" => "14 March 2025",
          "Decline date" => "14 March 2025",
          "Feedback date" => "14 March 2025",
          "Interview date" => "14 March 2025 2:30pm",
        }])
      end
    end

    context "when the dates are missing" do
      let(:date) { nil }

      it "links to add each one" do
        expect(page).to have_link("Add job offer date", href: add_date_path(:offered, "offered"))
        expect(page).to have_link("Add decline date", href: add_date_path(:offered, "declined"))
        expect(page).to have_link("Add feedback date", href: add_date_path(:interviewing, "unsuccessful_interview"))
        expect(page).to have_link("Add interview date and time", href: add_date_path(:interviewing, "interview_datetime"))
      end
    end
  end
end
