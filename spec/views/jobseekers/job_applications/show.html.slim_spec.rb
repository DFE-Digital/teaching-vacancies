require "rails_helper"

RSpec.describe "jobseekers/job_applications/show" do
  let(:show_view) { Capybara.string(rendered) }
  let(:jobseeker) { build_stubbed(:jobseeker) }
  let(:vacancy) { build_stubbed(:vacancy) }
  let(:job_application) { build_stubbed(:job_application, :status_shortlisted, jobseeker:, vacancy:) }
  let(:current_jobseeker) { jobseeker }

  before do
    allow(view).to receive_messages(current_jobseeker:, job_application:, vacancy:)

    render
  end

  describe "personal details section" do
    subject(:personal_details) { show_view.find_by_id("personal_details") }

    context "when the previous names field is filled in" do
      let(:job_application) { build_stubbed(:job_application, :status_shortlisted, jobseeker:, vacancy:, previous_names: "Georges Gilbert") }

      it { is_expected.to have_text("Previous namesGeorges Gilbert") }
    end

    context "when the previous names field is absent" do
      let(:job_application) { build_stubbed(:job_application, :status_shortlisted, jobseeker:, vacancy:, previous_names: "") }

      it { is_expected.to have_text("Previous namesNot entered") }
    end
  end

  describe "download buttons" do
    let(:withdrawn_inset_text) do
      "If you accidentally withdrew from this job, you can download a blank copy of the application form, fill it in and submit it directly to the school."
    end

    context "when jobseekers have withdrawn" do
      let(:job_application) { build_stubbed(:job_application, :status_withdrawn, jobseeker:, vacancy:) }

      it "shows download completed button" do
        expect(show_view).to have_link(
          "Download your completed application",
          href: jobseekers_job_application_download_path(job_application),
          class: "govuk-button--primary",
        )
      end

      it "shows download blank application form button" do
        expect(show_view).to have_link(
          "Download a blank application form",
          href: jobseekers_job_application_form_preview_path(job_application, :blank),
          class: "govuk-button--secondary",
        )
      end

      it "shows withdrawn inset text" do
        expect(show_view).to have_text(withdrawn_inset_text)
      end
    end

    context "when jobseekers have not withdrawn" do
      it "show download application" do
        expect(show_view).to have_link(
          "Download your completed application",
          href: jobseekers_job_application_download_path(job_application),
          class: "govuk-button--primary",
        )
      end

      it "does not show blank application button" do
        expect(show_view).to have_no_link(
          "Download a blank application form",
          href: "",
          class: "govuk-button--secondary",
        )
      end

      it "does not show withdrawn inset" do
        expect(show_view).to have_no_text(withdrawn_inset_text)
      end
    end
  end

  describe "banner" do
    subject(:banner) { show_view.find(".review-banner") }

    let(:selectors) do
      {
        header: "h1",
        tag: ".status-tag",
        delete_btn: ".delete-application",
        withdraw_btn: ".withdraw-application",
        download_btn: ".print-application",
        vacancy_form_btn: ".vacancy-form",
        view_link: ".view-listing-link",
      }
    end

    it "displays common elements" do
      expect(banner).to have_css(selectors[:header], text: "#{vacancy.job_title} at #{vacancy.organisation.name}")
      expect(banner).to have_css(selectors[:view_link], text: "View this listing (opens in new tab)")
      expect(banner).to have_link("View this listing (opens in new tab)", href: job_path(vacancy))
    end

    context "with active application" do
      let(:job_application) { build_stubbed(:job_application, :status_shortlisted, jobseeker:, vacancy:) }

      it "renders section" do
        expect(banner).to have_css(selectors[:tag], text: "shortlisted")

        expect(banner).to have_css(selectors[:withdraw_btn])
        expect(banner).to have_link("Withdraw", href: jobseekers_job_application_confirm_withdraw_path(job_application))
        expect(banner).to have_css(selectors[:download_btn])
        expect(banner).to have_link("Download your completed application", href: jobseekers_job_application_download_path(job_application))

        expect(banner).to have_no_css(selectors[:delete_btn])
        expect(banner).to have_no_css(selectors[:vacancy_form_btn])
      end
    end

    context "with inactive application", :versioning do
      let(:job_application) { create(:job_application, :status_unsuccessful_interview, self_disclosure_request: self_disclosure_request) }
      let(:self_disclosure_request) { create(:self_disclosure_request, :sent) }

      it "renders section" do
        expect(banner).to have_css(selectors[:tag], text: "unsuccessful")

        expect(banner).to have_css(selectors[:download_btn])
        expect(banner).to have_link("Download your completed application", href: jobseekers_job_application_download_path(job_application))

        expect(banner).to have_no_css(selectors[:delete_btn])
        expect(banner).to have_no_css(selectors[:withdraw_btn])
        expect(banner).to have_no_css(selectors[:vacancy_form_btn])
      end
    end
  end

  describe "quick links" do
    subject(:quick_links) { show_view.all(".navigation-list-component .navigation-list-component__anchor a") }

    context "with religious vacancy" do
      let(:jobseeker) { create(:jobseeker) }
      let(:vacancy) { create(:vacancy, :catholic) }
      let(:job_application) do
        create(:job_application, :status_shortlisted, :with_baptism_certificate, jobseeker:, vacancy:)
      end
      let(:expected_sections) do
        [
          "Personal details",
          "Professional status",
          "Qualifications",
          "Training and continuing professional development (CPD)",
          "Professional body memberships",
          "Work history",
          "Personal statement",
          "Religious information",
          "References",
          "Ask for support if you have a disability or other needs",
          "Declarations",
        ]
      end

      it "renders nav links" do
        expect(quick_links.map(&:text)).to match_array(expected_sections)
      end

      describe "sections" do
        subject(:sections) { show_view.all(".govuk-summary-card__title") }

        let(:expected_sections) do
          [
            "Personal details",
            "Professional status",
            "Qualifications",
            "Training and continuing professional development (CPD)",
            "Professional body memberships (optional)",
            "Work history",
            "Personal statement",
            "Religious information",
            "References",
            "Ask for support if you have a disability or other needs",
            "Declarations",
          ]
        end

        it "renders each section" do
          expect(sections.map(&:text)).to match_array(expected_sections)
        end
      end
    end

    context "with other vacancy" do
      let(:expected_sections) do
        [
          "Personal details",
          "Professional status",
          "Qualifications",
          "Training and continuing professional development (CPD)",
          "Professional body memberships",
          "Work history",
          "Personal statement",
          "References",
          "Ask for support if you have a disability or other needs",
          "Declarations",
        ]
      end

      it "renders nav links" do
        expect(quick_links.map(&:text)).to match_array(expected_sections)
      end

      describe "sections" do
        subject(:sections) { show_view.all(".govuk-summary-card__title") }

        let(:expected_sections) do
          [
            "Personal details",
            "Professional status",
            "Qualifications",
            "Training and continuing professional development (CPD)",
            "Professional body memberships (optional)",
            "Work history",
            "Personal statement",
            "References",
            "Ask for support if you have a disability or other needs",
            "Declarations",
          ]
        end

        it "renders each section" do
          expect(sections.map(&:text)).to match_array(expected_sections)
        end
      end
    end
  end

  describe "timeline" do
    subject(:timeline_items) { show_view.all(".timeline-component .timeline-component__item") }

    it "renders" do
      expect(timeline_items.map(&:text).join).to include("Application submitted")
    end
  end

  describe "self disclosure request banner" do
    let(:scope) { "jobseekers.job_applications.show.self_disclosure" }
    let(:call_to_action) do
      I18n.t(
        ".cta_html",
        scope:,
        organisation: job_application.vacancy.organisation.name,
        link: "self-disclosure form",
      )
    end
    let(:form_path) do
      jobseekers_job_application_self_disclosure_path(job_application, Wicked::FIRST_STEP)
    end

    context "when self_disclosure_request sent" do
      let(:job_application) { build_stubbed(:job_application, :status_interviewing, self_disclosure_request: self_disclosure_request) }
      let(:self_disclosure_request) { build_stubbed(:self_disclosure_request, :sent) }

      it { expect(rendered).to have_content(call_to_action) }
      it { expect(rendered).to have_link(I18n.t(".form", scope:), href: form_path) }
    end

    context "when self_disclosure_request manual" do
      let(:job_application) { build_stubbed(:job_application, :status_interviewing) }
      let(:self_disclosure_request) { build_stubbed(:self_disclosure_request, :manual, job_application:) }

      it { expect(rendered).to have_no_content(call_to_action) }
      it { expect(rendered).to have_no_link(I18n.t(".form", scope:), href: form_path) }
    end

    context "when job application not status interviewing" do
      it { expect(rendered).to have_no_content(call_to_action) }
      it { expect(rendered).to have_no_link(I18n.t(".form", scope:), href: form_path) }
    end
  end
end
