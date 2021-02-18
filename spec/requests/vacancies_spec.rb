require "rails_helper"

RSpec.describe "Vacancies", type: :request do
  describe "GET #index" do
    it "sets headers robots are asked to index but not to follow" do
      get jobs_path
      expect(response.headers["X-Robots-Tag"]).to eq("noarchive")
    end
  end

  describe "GET #show" do
    subject { get job_path(vacancy), params: params }

    context "when vacancy is trashed" do
      let(:vacancy) { create(:vacancy, :trashed) }
      let(:params) { { id: vacancy.id } }

      it "renders errors/trashed_vacancy_found" do
        expect(subject).to render_template("errors/trashed_vacancy_found")
      end

      it "returns not found" do
        subject
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when vacancy does not exist" do
      let(:vacancy) { "missing-id" }

      let(:params) { { id: "missing-id" } }

      it "renders errors/not_found" do
        expect(subject).to render_template("errors/not_found")
      end

      it "returns not found" do
        subject
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when using cookies" do
      let(:school) { create(:school) }
      let(:vacancy) { create(:vacancy) }
      let(:params) { { id: vacancy.slug } }
      let(:vacancy_page_view) { instance_double(VacancyPageView) }

      before do
        vacancy.organisation_vacancies.create(organisation: school)
      end

      it "calls the track method if cookies not set" do
        expect(PersistVacancyPageViewJob).to receive(:perform_later).with(vacancy.id)
        subject
      end

      it "does not call the track method if smoke_test cookies set" do
        expect(PersistVacancyPageViewJob).not_to receive(:perform_later)
        cookies[:smoke_test] = "1"
        subject
      end
    end
  end
end
