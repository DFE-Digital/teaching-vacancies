require "rails_helper"

RSpec.describe "Vacancies" do
  describe "GET #index" do
    it "sets headers robots are asked to index but not to follow" do
      get jobs_path
      expect(response.headers["X-Robots-Tag"]).to eq("noarchive")
    end
  end

  describe "GET #show" do
    subject { get job_path(vacancy), params: }

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
  end
end
