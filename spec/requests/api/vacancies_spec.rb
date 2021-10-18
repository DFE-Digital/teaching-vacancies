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
        .to eq(terms_and_conditions_url(anchor: "api"))
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
          self: "http://localhost:3000/api/v1/jobs.json?page=2",
          first: "http://localhost:3000/api/v1/jobs.json?page=1",
          last: "http://localhost:3000/api/v1/jobs.json?page=4",
          next: "http://localhost:3000/api/v1/jobs.json?page=3",
          prev: "http://localhost:3000/api/v1/jobs.json?page=1",
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

    it "returns status :not_found if the request format is not JSON" do
      get api_job_path(vacancy.slug, api_version: 1), params: { format: :html }

      expect(response.status).to eq(Rack::Utils.status_code(:not_found))
    end

    context "sets headers" do
      before(:each) { get api_job_path(vacancy.slug, api_version: 1), params: { format: :json } }

      it_behaves_like "X-Robots-Tag"
      it_behaves_like "Content-Type JSON"
    end

    it "returns status code :ok" do
      get api_job_path(vacancy.slug, api_version: 1), params: { format: :json }

      expect(response.status).to eq(Rack::Utils.status_code(:ok))
    end

    it "never redirects to latest url" do
      vacancy = create(:vacancy, :published)
      vacancy.job_title = "A new job title"
      vacancy.refresh_slug
      vacancy.save

      get api_job_path(vacancy.slug, api_version: 1), params: { format: :json }
      expect(response.status).to eq(Rack::Utils.status_code(:ok))
    end

    context "format" do
      it "maps vacancy to the JobPosting schema" do
        get api_job_path(vacancy.slug, api_version: 1), params: { format: :json }

        expect(json.to_h).to eq(vacancy_json_ld(VacancyPresenter.new(vacancy)))
      end

      describe "#employment_type" do
        it "maps full_time working pattern to FULL_TIME" do
          vacancy = create(:vacancy, working_patterns: %w[full_time])

          get api_job_path(vacancy.slug, api_version: 1), params: { format: :json }

          expect(json.to_h).to include(employmentType: "FULL_TIME")
        end

        it "maps part_time working pattern to PART_TIME" do
          vacancy = create(:vacancy, working_patterns: %w[part_time])

          get api_job_path(vacancy.slug, api_version: 1), params: { format: :json }

          expect(json.to_h).to include(employmentType: "PART_TIME")
        end

        it "maps job_share working pattern to JOB_SHARE" do
          vacancy = create(:vacancy, working_patterns: %w[job_share])

          get api_job_path(vacancy.slug, api_version: 1), params: { format: :json }

          expect(json.to_h).to include(employmentType: "JOB_SHARE")
        end

        it "maps multiple values to an array" do
          vacancy = create(:vacancy, working_patterns: %w[part_time job_share])

          get api_job_path(vacancy.slug, api_version: 1), params: { format: :json }

          expect(json.to_h).to include(employmentType: "PART_TIME, JOB_SHARE")
        end
      end

      describe "#hiringOrganization" do
        it "sets the school's details" do
          get api_job_path(vacancy.slug, api_version: 1), params: { format: :json }

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
