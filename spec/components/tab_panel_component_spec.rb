require "rails_helper"

RSpec.describe TabPanelComponent, type: :component do
  subject!(:tab_panel) { Capybara.string(render_component) }

  let(:component) { described_class.new(tab_name:, vacancy:, candidates:, form:, displayed_fields:) }
  let(:render_component) { render_inline(component) }
  let(:displayed_fields) { %i[name email_address status] }
  let(:form) { nil }
  let(:tab_name) { "submitted" }
  let(:vacancy) { build_stubbed(:vacancy) }
  let(:candidates) { build_stubbed_list(:job_application, 2, :status_submitted, vacancy:) }

  context "when form present" do
    let(:form) { Publishers::JobApplication::TagForm.new }

    it "job application can be selected" do
      expect(tab_panel.all('input[type="checkbox"]')).not_to be_empty
    end

    it "form points to url" do
      expected_url = Rails.application.routes.url_helpers.tag_organisation_job_job_applications_path(vacancy.id)
      expect(tab_panel.find("form")["action"]).to eq(expected_url)
      expect(tab_panel.find("form")["method"]).to eq("get")
    end

    it "table has moj multi select attributes" do
      expect(tab_panel.find("table")["data-module"]).to eq("moj-multi-select")
    end

    it "has buttons" do
      expect(tab_panel.all(".govuk-button-group")).not_to be_empty
    end

    describe "#candidate_name" do
      let(:candidate) { build_stubbed(:job_application, :status_submitted, vacancy:) }
      let(:candidates) { [candidate] }

      it "has a link to the candidate" do
        expect(tab_panel.all("a").map(&:text)).to include(candidate.name)
      end

      context "with a withdrawn candidate" do
        let(:candidate) { build_stubbed(:job_application, :status_withdrawn, vacancy:) }

        it "does not link to the candidate" do
          expect(tab_panel.all("a").map(&:text)).not_to include(candidate.name)
        end
      end
    end
  end

  context "when form is nil" do
    it "job application cannot be selected" do
      expect(tab_panel.all('input[type="checkbox"]')).to be_empty
    end

    it "form points to no url" do
      expect(tab_panel.find("form")["action"]).to eq("")
    end

    it "table has moj multi select attributes" do
      expect(tab_panel.find("table")["data-module"]).to be_nil
    end

    it "has no buttons" do
      expect(tab_panel.all(".govuk-button-group")).to be_empty
    end
  end

  context "when candidates empty" do
    let(:candidates) { [] }

    it "renders empty section" do
      expect(tab_panel.find(".empty-section-component")).to be_present
    end
  end

  context "when rendering candidate's offered_at date" do
    let(:candidates) { build_stubbed_list(:job_application, 1, :status_offered, vacancy:, offered_at: Time.zone.now) }
    let(:displayed_fields) { %i[name email_address offered_at] }
    let(:expected_date) { candidates.first.offered_at.to_fs(:day_month_year) }

    it { expect(tab_panel.find(".offered_at")).to have_text(expected_date) }
    it { expect(component.candidate_offered_at(candidates.first)).to eq(expected_date) }

    context "when date nil" do
      let(:candidates) { build_stubbed_list(:job_application, 1, :status_offered, vacancy:, offered_at: nil) }

      it { expect(tab_panel.find(".offered_at")).to have_link("Add job offer date", href: Rails.application.routes.url_helpers.tag_organisation_job_job_applications_path(vacancy.id, params: { publishers_job_application_tag_form: { origin: :offered, job_applications: [candidates.first] }, tag_action: "offered" })) }
    end
  end

  context "when rendering candidate's declined_at date" do
    let(:candidates) { build_stubbed_list(:job_application, 1, :status_declined, vacancy:, declined_at: Time.zone.now) }
    let(:displayed_fields) { %i[name email_address declined_at] }
    let(:expected_date) { candidates.first.declined_at.to_fs(:day_month_year) }

    it { expect(tab_panel.find(".declined_at")).to have_text(expected_date) }
    it { expect(component.candidate_declined_at(candidates.first)).to eq(expected_date) }

    context "when date nil" do
      let(:candidates) { build_stubbed_list(:job_application, 1, :status_declined, vacancy:, declined_at: nil) }

      it { expect(tab_panel.find(".declined_at")).to have_link("Add decline date", href: Rails.application.routes.url_helpers.tag_organisation_job_job_applications_path(vacancy.id, params: { publishers_job_application_tag_form: { origin: :offered, job_applications: [candidates.first] }, tag_action: "declined" })) }
    end
  end

  context "when rendering candidate's feedback date" do
    let(:candidates) { build_stubbed_list(:job_application, 1, :status_unsuccessful_interview, vacancy:, interview_feedback_received_at: Time.zone.now) }
    let(:displayed_fields) { %i[name email_address interview_feedback_received_at] }
    let(:expected_date) { candidates.first.interview_feedback_received_at.to_fs(:day_month_year) }

    it { expect(tab_panel.find(".interview_feedback_received_at")).to have_text(expected_date) }
    it { expect(component.candidate_interview_feedback_received_at(candidates.first)).to eq(expected_date) }

    context "when date nil" do
      let(:candidates) { build_stubbed_list(:job_application, 1, :status_unsuccessful_interview, vacancy:, interview_feedback_received_at: nil) }

      it { expect(tab_panel.find(".interview_feedback_received_at")).to have_link("Add feedback date", href: Rails.application.routes.url_helpers.tag_organisation_job_job_applications_path(vacancy.id, params: { publishers_job_application_tag_form: { origin: :interviewing, job_applications: [candidates.first] }, tag_action: "unsuccessful_interview" })) }
    end
  end

  context "when rendering candidate's interview datetime" do
    let(:candidates) { build_stubbed_list(:job_application, 1, :status_interviewing, vacancy:, interviewing_at: Time.zone.now) }
    let(:displayed_fields) { %i[name email_address interviewing_at] }
    let(:expected_date) { candidates.first.interviewing_at.to_fs }

    it { expect(tab_panel.find(".interviewing_at")).to have_text(expected_date) }
    it { expect(component.candidate_interviewing_at(candidates.first)).to eq(expected_date) }

    context "when date nil" do
      let(:candidates) { build_stubbed_list(:job_application, 1, :status_interviewing, vacancy:, interviewing_at: nil) }

      it { expect(tab_panel.find(".interviewing_at")).to have_link("Add interview date and time", href: Rails.application.routes.url_helpers.tag_organisation_job_job_applications_path(vacancy.id, params: { publishers_job_application_tag_form: { origin: :interviewing, job_applications: [candidates.first] }, tag_action: "interview_datetime" })) }
    end
  end
end
