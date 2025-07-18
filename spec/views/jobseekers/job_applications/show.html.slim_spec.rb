require "rails_helper"

RSpec.describe "jobseekers/job_applications/show" do
  let(:show_view) { Capybara.string(rendered) }
  let(:jobseeker) { build_stubbed(:jobseeker) }
  let(:vacancy) { build_stubbed(:vacancy) }
  let(:job_application) { build_stubbed(:job_application, :status_shortlisted, jobseeker:, vacancy:) }
  let(:current_jobseeker) { jobseeker }

  before do
    without_partial_double_verification do
      allow(view).to receive_messages(current_jobseeker:, job_application:, vacancy:)
    end

    render
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
        view_link: ".view-listing-link",
      }
    end

    it "renders section" do
      expect(banner).to have_css(selectors[:header], text: "#{vacancy.job_title} at #{vacancy.organisation.name}")
      expect(banner).to have_css(selectors[:tag], text: "shortlisted")

      expect(banner).to have_css(selectors[:view_link], text: "View this listing (opens in new tab)")
      expect(banner).to have_link("View this listing (opens in new tab)", href: job_path(vacancy))

      expect(banner).to have_css(selectors[:download_btn])
      expect(banner).to have_css(selectors[:withdraw_btn])
      expect(banner).to have_link("Withdraw", href: jobseekers_job_application_confirm_withdraw_path(job_application))

      expect(banner).to have_no_css(selectors[:delete_btn])
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
      expect(timeline_items.map(&:text)).to contain_exactly("Application submitted")
    end
  end
end
