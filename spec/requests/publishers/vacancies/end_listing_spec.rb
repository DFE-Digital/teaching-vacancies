require "rails_helper"

RSpec.describe "End job listing early", type: :request do
  let(:organisation) { build(:school) }
  let(:vacancy) { create(:vacancy, :published, expires_at: 1.week.from_now, organisation_vacancies_attributes: [{ organisation: organisation }]) }
  let(:publisher) { create(:publisher) }

  before do
    allow(DisableExpensiveJobs).to receive(:enabled?).and_return(false)
    allow_any_instance_of(Publishers::AuthenticationConcerns).to receive(:current_organisation).and_return(organisation)
    sign_in(publisher, scope: :publisher)
  end

  describe "GET #show" do
    context "when the vacancy does not belong to the current organisation" do
      let(:vacancy) { create(:vacancy, :published, organisation_vacancies_attributes: [{ organisation: build(:school) }]) }

      it "returns not_found" do
        get organisation_job_end_listing_path(vacancy.id)

        expect(response).to have_http_status(:not_found)
      end
    end

    context "when the vacancy is not live" do
      let(:vacancy) { create(:vacancy, :expired, organisation_vacancies_attributes: [{ organisation: organisation }]) }

      it "returns not_found" do
        get(organisation_job_end_listing_path(vacancy.id))

        expect(response).to have_http_status(:not_found)
      end
    end

    it "renders the show page" do
      expect(get(organisation_job_end_listing_path(vacancy.id))).to render_template(:show)
    end
  end

  describe "PATCH #update" do
    let(:button) { I18n.t("buttons.end_listing") }
    let(:params) { { publishers_job_listing_end_listing_form: { end_listing_reason: "end_early" }, commit: button } }

    context "when the vacancy does not belong to the current organisation" do
      let(:vacancy) { create(:vacancy, organisation_vacancies_attributes: [{ organisation: build(:school) }]) }

      it "returns not_found" do
        patch(organisation_job_end_listing_path(vacancy.id), params: params)

        expect(response).to have_http_status(:not_found)
      end
    end

    context "when the vacancy is not live" do
      let(:vacancy) { create(:vacancy, :expired, organisation_vacancies_attributes: [{ organisation: organisation }]) }

      it "returns not_found" do
        patch(organisation_job_end_listing_path(vacancy.id), params: params)

        expect(response).to have_http_status(:not_found)
      end
    end

    context "when the commit param is `Cancel`" do
      let(:button) { I18n.t("buttons.cancel") }

      it "does not update expires_at, end_listing_reason, google index and redirects to the dashboard" do
        expect { patch(organisation_job_end_listing_path(vacancy.id), params: params) }
          .to not_change { vacancy.reload.expires_at }
          .and not_change { vacancy.reload.end_listing_reason }
          .and not_have_enqueued_job(UpdateGoogleIndexQueueJob)

        expect(response).to redirect_to(jobs_with_type_organisation_path(:published))
      end
    end

    it "updates expires_at, end_listing_reason, google index and redirects to the dashboard" do
      freeze_time do
        expect { patch(organisation_job_end_listing_path(vacancy.id), params: params) }
          .to change { vacancy.reload.expires_at }.from(1.week.from_now).to(Time.current)
          .and change { vacancy.reload.end_listing_reason }.from(nil).to("end_early")
          .and have_enqueued_job(UpdateGoogleIndexQueueJob)

        expect(response).to redirect_to(jobs_with_type_organisation_path(:expired))
      end
    end
  end
end
