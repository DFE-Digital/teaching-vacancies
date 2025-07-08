require "rails_helper"

RSpec.describe "jobseekers/job_applications/show" do
  let(:show_view) { jobseeker_application_page }
  let(:jobseeker) { build_stubbed(:jobseeker) }
  let(:vacancy) { build_stubbed(:vacancy) }
  let(:job_application) { build_stubbed(:job_application, :status_shortlisted, jobseeker:, vacancy:) }
  let(:current_jobseeker) { jobseeker }

  before do
    without_partial_double_verification do
      allow(view).to receive_messages(current_jobseeker:, job_application:, vacancy:)
    end

    render

    show_view.load(rendered)
  end

  describe "banner" do
    subject(:banner) { show_view.banner }

    it "renders section" do
      expect(banner.header).to have_text("#{vacancy.job_title} at #{vacancy.organisation.name}")
      expect(banner.tag).to have_text("shortlisted")

      expect(banner.view_link).to have_text("View this listing (opens in new tab)")
      expect(banner.view_link["href"]).to eq(job_path(vacancy))

      expect(banner).to have_download_btn
      expect(banner).to have_withdraw_btn
      expect(banner.withdraw_btn["href"]).to eq(jobseekers_job_application_confirm_withdraw_path(job_application))

      expect(banner).to have_no_delete_btn
    end
  end

  describe "quick links" do
    subject(:quick_links) { show_view.quick_links }

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
        expect(quick_links.items.map(&:text)).to match_array(expected_sections)
      end

      describe "sections" do
        subject(:sections) { show_view.review_sections }

        context "when jobseeker logged in" do
          let(:current_jobseeker) { jobseeker }

          it "renders" do
            sections.each.with_index do |section, index|
              expect(section).to have_header
              expect(section.header).to have_text(expected_sections[index])
            end
          end
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
        expect(quick_links.items.map(&:text)).to match_array(expected_sections)
      end

      describe "sections" do
        subject(:sections) { show_view.review_sections }

        context "when jobseeker logged in" do
          let(:current_jobseeker) { jobseeker }

          it "renders" do
            sections.each.with_index do |section, index|
              expect(section).to have_header
              expect(section.header).to have_text(expected_sections[index])
            end
          end
        end
      end
    end
  end

  describe "timeline" do
    it "renders" do
      expect(show_view.timeline.items.map(&:text)).to contain_exactly("Application submitted")
    end
  end
end
