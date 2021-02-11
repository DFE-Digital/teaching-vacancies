require "rails_helper"

RSpec.describe VacanciesController, type: :controller do
  describe "sets headers" do
    it "robots are asked to index but not to follow" do
      get :index
      expect(response.headers["X-Robots-Tag"]).to eq("noarchive")
    end
  end

  describe "#index" do
    subject { get :index, params: params }

    context "jobs_sort option" do
      let(:params) do
        {
          keyword: "Business Studies",
          location: "Torquay",
          jobs_sort: sort,
        }
      end

      context "when parameters include the sort by newest listing option" do
        let(:sort) { "publish_on_desc" }

        it "sets the search replica on Search::VacancySearch" do
          subject
          expect(controller.instance_variable_get(:@vacancies_search).search_replica).to eq("#{Indexable::INDEX_NAME}_#{sort}")
        end
      end

      context "when parameters include the sort by most time to apply option" do
        let(:sort) { "expires_at_desc" }

        it "sets the search replica on Search::VacancySearch" do
          subject
          expect(controller.instance_variable_get(:@vacancies_search).search_replica).to eq("#{Indexable::INDEX_NAME}_#{sort}")
        end
      end

      context "when parameters include the sort by least time to apply option" do
        let(:sort) { "expires_at_asc" }

        it "sets the search replica on Search::VacancySearch" do
          subject
          expect(controller.instance_variable_get(:@vacancies_search).search_replica).to eq("#{Indexable::INDEX_NAME}_#{sort}")
        end
      end

      context "when parameters do not include a keyword" do
        let(:params) do
          {
            keyword: "",
            location: "Torquay",
            jobs_sort: "",
          }
        end

        it "sets the search replica on Search::VacancySearch to the default sort strategy: newest listing" do
          subject
          expect(controller.instance_variable_get(:@vacancies_search).search_replica).to eq("#{Indexable::INDEX_NAME}_publish_on_desc")
        end
      end
    end
  end

  describe "#show" do
    subject { get :show, params: params }

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
