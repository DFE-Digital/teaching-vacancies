require "rails_helper"

RSpec.describe "End job listing early" do
  let(:organisation) { build(:school) }
  let(:vacancy) { create(:vacancy, :published, expires_at: 1.week.from_now, organisations: [organisation]) }
  let(:publisher) { create(:publisher) }

  before do
    allow(DisableExpensiveJobs).to receive(:enabled?).and_return(false)
    allow_any_instance_of(Publishers::AuthenticationConcerns).to receive(:current_organisation).and_return(organisation)
    sign_in(publisher, scope: :publisher)
  end

  describe "GET #show" do
    context "when the vacancy does not belong to the current organisation" do
      let(:vacancy) { create(:vacancy, :published, organisations: [build(:school)]) }

      it "returns not_found" do
        get organisation_job_end_listing_path(vacancy.id)

        expect(response).to have_http_status(:not_found)
      end
    end

    context "when the vacancy is not live" do
      let(:vacancy) { create(:vacancy, :expired, organisations: [organisation]) }

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
    let(:params) { { publishers_job_listing_end_listing_form: { hired_status: "hired_other_free", listed_elsewhere: "listed_free" } } }

    context "when the vacancy does not belong to the current organisation" do
      let(:vacancy) { create(:vacancy, organisations: [build(:school)]) }

      it "returns not_found" do
        patch(organisation_job_end_listing_path(vacancy.id), params: params)

        expect(response).to have_http_status(:not_found)
      end
    end

    context "when the vacancy is not live" do
      let(:vacancy) { create(:vacancy, :expired, organisations: [organisation]) }

      it "returns not_found" do
        patch(organisation_job_end_listing_path(vacancy.id), params: params)

        expect(response).to have_http_status(:not_found)
      end
    end

    it "updates expires_at, hired_status, listed_elsewhere, google index and redirects to the dashboard" do
      freeze_time do
        expect { patch(organisation_job_end_listing_path(vacancy.id), params: params) }
          .to change { vacancy.reload.expires_at }.from(1.week.from_now).to(Time.current)
          .and change { vacancy.reload.hired_status }.from(nil).to("hired_other_free")
          .and change { vacancy.reload.listed_elsewhere }.from(nil).to("listed_free")
          .and have_enqueued_job(UpdateGoogleIndexQueueJob)

        expect(response).to redirect_to(organisation_job_path(vacancy.id))
      end
    end
  end
end
