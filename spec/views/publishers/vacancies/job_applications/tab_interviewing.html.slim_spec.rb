require "rails_helper"

RSpec.describe "publishers/vacancies/job_applications/_tab_interviewing" do
  before do
    render "publishers/vacancies/job_applications/tab_interviewing",
           tab_name: "interviewing",
           candidates: { "interviewing" => interview_candidates.map(&:decorate), "unsuccessful_interview" => unsuccessful_candidates.map(&:decorate) },
           form: Publishers::JobApplication::TagForm.new, vacancy: vacancy
  end

  let(:vacancy) { build_stubbed(:vacancy) }
  let(:interview_candidates) { build_stubbed_list(:job_application, 2, :status_interviewing, vacancy:) }
  let(:unsuccessful_candidates) { build_stubbed_list(:job_application, 1, :status_unsuccessful_interview, vacancy:) }
  let(:page) { Capybara.string(rendered) }

  describe "interviewing panel" do
    let(:tab_panel) { page.find(".tab-interviewing") }

    it "job application can be selected" do
      expect(tab_panel.all('input[type="checkbox"]')).not_to be_empty
    end

    it "form points to url" do
      expected_url = tag_organisation_job_job_applications_path(vacancy.id)
      expect(tab_panel.find("form")["action"]).to eq(expected_url)
      expect(tab_panel.find("form")["method"]).to eq("get")
    end

    it "table has multi select attributes" do
      expect(tab_panel.find("table")["data-controller"]).to eq("multi-select")
    end

    it "has buttons" do
      expect(tab_panel.all(".govuk-button-group")).not_to be_empty
    end

    context "when candidates empty" do
      let(:interview_candidates) { [] }

      it "renders empty section" do
        expect(tab_panel.find(".empty-section-component")).to be_present
      end
    end

    context "when rendering candidate's interview datetime" do
      let(:interview_candidates) { [candidate] }

      context "with a date" do
        let(:candidate) { build_stubbed(:job_application, :status_interviewing, vacancy:) }

        it { expect(tab_panel.find(".interviewing_at")).to have_text(candidate.interviewing_at.to_fs) }
      end

      context "when date nil" do
        let(:candidate) { build_stubbed(:job_application, :status_interviewing, vacancy:, interviewing_at: nil) }

        it {
          expect(tab_panel.find(".interviewing_at"))
               .to have_link("Add interview date and time",
                             href: tag_organisation_job_job_applications_path(vacancy.id,
                                                                              params: { publishers_job_application_tag_form: {
                                                                                          origin: :interviewing, job_applications: [candidate]
                                                                                        },
                                                                                        tag_action: "interview_datetime" }))
        }
      end
    end

    describe "#sort_candidates" do
      let(:first_candidate) { build_stubbed(:job_application, :status_interviewing, interviewing_at: Date.new(2025, 1, 3)) }
      let(:nil_candidate) { build_stubbed(:job_application, :status_interviewing, interviewing_at: nil) }
      let(:early_candidate) { build_stubbed(:job_application, :status_interviewing, interviewing_at: Date.new(2025, 1, 1)) }
      let(:interview_candidates) { [first_candidate, nil_candidate, early_candidate] }

      let(:result) { page.all(".application-interviewing a").map(&:text).reject { |n| ["Pre-interview checks", "Add interview date and time"].include?(n) } }

      it "sorts candidates with nil interviewing_at first, then by date" do
        expect(result).to eq([nil_candidate, early_candidate, first_candidate].map(&:name))
      end
    end
  end

  describe "unsuccessful interview panel" do
    let(:tab_panel) { page.find(".tab-unsuccessful_interview") }

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

    context "when rendering candidate's feedback date" do
      let(:unsuccessful_candidates) { build_stubbed_list(:job_application, 1, :status_unsuccessful_interview, vacancy:, interview_feedback_received_at: Time.zone.now) }
      let(:expected_date) { unsuccessful_candidates.first.interview_feedback_received_at.to_fs(:day_month_year) }

      it { expect(tab_panel.find(".interview_feedback_received_at")).to have_text(expected_date) }

      context "when date nil" do
        let(:unsuccessful_candidates) { build_stubbed_list(:job_application, 1, :status_unsuccessful_interview, vacancy:, interview_feedback_received_at: nil) }

        it {
          expect(tab_panel.find(".interview_feedback_received_at"))
                 .to have_link("Add feedback date",
                               href: tag_organisation_job_job_applications_path(vacancy.id,
                                                                                params: { publishers_job_application_tag_form: {
                                                                                            origin: :interviewing, job_applications: [unsuccessful_candidates.first]
                                                                                          },
                                                                                          tag_action: "unsuccessful_interview" }))
        }
      end
    end
  end
end
