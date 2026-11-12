require "rails_helper"

RSpec.describe "publishers/vacancies/job_applications/_tab_offered" do
  before do
    render "publishers/vacancies/job_applications/tab_offered",
           tab_name: "offered",
           candidates: { "offered" => offered_candidates.map(&:decorate), "declined" => declined_candidates.map(&:decorate) },
           form: Publishers::JobApplication::TagForm.new, vacancy: vacancy
  end

  let(:vacancy) { build_stubbed(:vacancy) }
  let(:offered_candidates) { build_stubbed_list(:job_application, 2, :status_offered, vacancy:) }
  let(:declined_candidates) { build_stubbed_list(:job_application, 1, :status_declined, vacancy:) }
  let(:page) { Capybara.string(rendered) }

  describe "offered panel" do
    let(:tab_panel) { page.find(".tab-offered") }

    context "when rendering candidate's offered_at date" do
      let(:offered_candidates) { build_stubbed_list(:job_application, 1, :status_offered, vacancy:, offered_at: Time.zone.now) }
      let(:displayed_fields) { %i[name email_address offered_at] }
      let(:expected_date) { offered_candidates.first.offered_at.to_fs(:day_month_year) }

      it { expect(tab_panel.find(".offered_at")).to have_text(expected_date) }

      context "when date nil" do
        let(:offered_candidates) { build_stubbed_list(:job_application, 1, :status_offered, vacancy:, offered_at: nil) }

        it {
          expect(tab_panel.find(".offered_at"))
               .to have_link("Add job offer date",
                             href: tag_organisation_job_job_applications_path(vacancy.id,
                                                                              params: {
                                                                                publishers_job_application_tag_form: { origin: :offered,
                                                                                                                       job_applications: [offered_candidates.first] },
                                                                                tag_action: "offered",
                                                                              }))
        }
      end
    end
  end

  context "when rendering candidate's declined_at date" do
    let(:tab_panel) { page.find(".tab-declined") }
    let(:declined_candidates) { build_stubbed_list(:job_application, 1, :status_declined, vacancy:, declined_at: Time.zone.now) }
    let(:expected_date) { declined_candidates.first.declined_at.to_fs(:day_month_year) }

    it { expect(tab_panel.find(".declined_at")).to have_text(expected_date) }

    context "when date nil" do
      let(:declined_candidates) { build_stubbed_list(:job_application, 1, :status_declined, vacancy:, declined_at: nil) }

      it {
        expect(tab_panel.find(".declined_at"))
             .to have_link("Add decline date",
                           href: tag_organisation_job_job_applications_path(vacancy.id,
                                                                            params: { publishers_job_application_tag_form: {
                                                                                        origin: :offered,
                                                                                        job_applications: [declined_candidates.first],
                                                                                      },
                                                                                      tag_action: "declined" }))
      }
    end
  end
end
