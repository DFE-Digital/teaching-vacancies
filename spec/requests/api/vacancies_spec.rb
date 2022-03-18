require "rails_helper"

RSpec.describe "Api::Vacancies" do
  let(:json) { JSON.parse(response.body, symbolize_names: true) }
  let(:school) { create(:school) }

  describe "GET /api/v1/jobs.html" do
    it "returns status :not_found as only JSON format is allowed" do
      get api_jobs_path(api_version: 1), params: { format: :html }

      expect(response.status).to eq(Rack::Utils.status_code(:not_found))
    end
  end

  describe "GET /api/v1/jobs.json", json: true do
    context "sets headers" do
      before(:each) { get api_jobs_path(api_version: 1), params: { format: :json } }

      it_behaves_like "X-Robots-Tag"
      it_behaves_like "Content-Type JSON"
    end

    it "returns status :not_found if the request format is not JSON" do
      get api_jobs_path(api_version: 1), params: { format: :html }

      expect(response.status).to eq(Rack::Utils.status_code(:not_found))
    end

    it "returns the API's openapi version" do
      get api_jobs_path(api_version: 1), params: { format: :json }

      expect(json[:openapi]).to eq("3.0.0")
    end

    it "returns the API's info" do
      get api_jobs_path(api_version: 1), params: { format: :json }

      info_object = json[:info]
      expect(info_object[:title]).to eq("GOV UK - #{I18n.t('app.title')}")
      expect(info_object[:description]).to eq(I18n.t("app.description"))
      expect(info_object[:termsOfService])
        .to eq(page_url("terms-and-conditions", anchor: "terms-and-conditions-for-api-users"))
      expect(info_object[:contact][:email]).to eq(I18n.t("help.email"))
    end

    it "returns a links object" do
      get api_jobs_path(api_version: 1), params: { format: :json }

      expect(json[:links].keys).to include(:self, :first, :last, :prev, :next)
    end

    it "retrieves all live vacancies" do
      published_vacancy = create(:vacancy, organisations: [school])
      create(:vacancy, :expired, organisations: [school])

      get api_jobs_path(api_version: 1), params: { format: :json }

      expect(response.status).to eq(Rack::Utils.status_code(:ok))
      expect(json[:data].count).to eq(1)
      expect(json[:data]).to include(vacancy_json_ld(VacancyPresenter.new(published_vacancy)))
    end

    context "when there are more vacancies than the per-page limit" do
      before do
        stub_const("Api::VacanciesController::MAX_API_RESULTS_PER_PAGE", per_page)
        create_list(:vacancy, 16)

        get api_jobs_path(api_version: 1), params: { page: 2, format: :json }
      end

      let(:per_page) { 5 }
      let(:links_object) { json[:links] }

      it "paginates the result" do
        expect(json[:data].count).to eq(per_page)
      end

      it "includes the correct pagination links" do
        expect(links_object).to include(
          self: api_jobs_url(page: 2, format: :json),
          first: api_jobs_url(page: 1, format: :json),
          last: api_jobs_url(page: 4, format: :json),
          next: api_jobs_url(page: 3, format: :json),
          prev: api_jobs_url(page: 1, format: :json),
        )
      end

      it "includes the total pages" do
        expect(json[:meta]).to include(totalPages: 4)
      end
    end

    it "does not retrieve incomplete or deleted vacancies" do
      create(:vacancy, :draft)
      create(:vacancy, :trashed)
      create(:vacancy, :future_publish)

      get api_jobs_path(api_version: 1), params: { format: :json }

      expect(response.status).to eq(Rack::Utils.status_code(:ok))
      expect(json[:data].count).to eq(0)
    end
  end

  describe "GET /api/v1/jobs/:id.json", json: true do
    let(:vacancy) { create(:vacancy, organisations: [school]) }

    subject do
      get api_job_path(vacancy.slug, api_version: 1), params: { format: :json }
    end

    it "returns status :not_found if the request format is not JSON" do
      get api_job_path(vacancy.slug, api_version: 1), params: { format: :html }

      expect(response.status).to eq(Rack::Utils.status_code(:not_found))
    end

    it "still monitors API usage if the request is for an entity that is not found" do
      expect {
        get api_job_path("slug-that-does-not-exist", api_version: 1), params: { format: :json }
      }.to have_triggered_event(:api_queried).with_data({ not_found: "true" })
    end

    context "sets headers" do
      before { subject }

      it_behaves_like "X-Robots-Tag"
      it_behaves_like "Content-Type JSON"
    end

    it "returns status code :ok" do
      subject
      expect(response.status).to eq(Rack::Utils.status_code(:ok))
    end

    it "does not trigger a page_visited event" do
      expect { subject }.not_to have_triggered_event(:page_visited)
    end

    it "triggers an api_queried event" do
      expect { subject }.to have_triggered_event(:api_queried)
    end

    it "never redirects to latest url" do
      vacancy = create(:vacancy, :published)
      vacancy.job_title = "A new job title"
      vacancy.refresh_slug
      vacancy.save

      subject
      expect(response.status).to eq(Rack::Utils.status_code(:ok))
    end

    context "format" do
      before { subject }

      it "maps vacancy to the JobPosting schema" do
        expect(json.to_h).to eq(vacancy_json_ld(VacancyPresenter.new(vacancy)))
      end

      describe "#employment_type" do
        let(:vacancy) { create(:vacancy, working_patterns: working_patterns) }

        context "with single working patterns" do
          let(:working_patterns) { %w[full_time part_time] }

          it "maps full_time working pattern to Full time, part time" do
            expect(json.to_h).to include(employmentType: %w[FULL_TIME PART_TIME])
          end
        end
      end

      describe "#hiringOrganization" do
        it "sets the school's details" do
          hiring_organization = {
            hiringOrganization: {
              "@type": "Organization",
              name: vacancy.parent_organisation.name,
              identifier: vacancy.parent_organisation.urn,
              description: "<p>#{vacancy.about_school}</p>",
            },
          }
          expect(json.to_h).to include(hiring_organization)
        end
      end
    end
  end
end
