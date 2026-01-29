require "rails_helper"

RSpec.describe "Sitemap" do
  describe "GET /sitemap.xml" do
    subject(:xml) { response.body }

    let!(:live_vacancy) { create(:vacancy, :live) }
    let!(:expired_vacancy) { create(:vacancy, :expired) }

    before do
      allow(Rails.application.config).to receive(:landing_pages).and_return({ "maths-teacher" => {} })

      get sitemap_path(format: :xml)
    end

    it "returns a successful response" do
      expect(response).to have_http_status(:success)
    end

    it "returns XML content" do
      expect(response.content_type).to include("application/xml")
    end

    it "includes live vacancies in the sitemap" do
      expect(xml).to include(job_path(live_vacancy))
    end

    it "excludes expired vacancies from the sitemap" do
      expect(xml).not_to include(job_path(expired_vacancy))
    end

    it "includes landing pages in the sitemap" do
      expect(xml).to include(landing_page_path("maths-teacher"))
    end

    it "includes location landing pages in the sitemap" do
      # Test for at least one location landing page
      expect(xml).to include(location_landing_page_path(ALL_IMPORTED_LOCATIONS.first))
    end

    it "includes static pages in the sitemap" do
      expect(xml).to include(page_path("terms-and-conditions"))
      expect(xml).to include(page_path("accessibility"))
    end

    it "includes posts in the sitemap" do
      expect(xml).to include(post_path("get-help-hiring", "how-to-create-job-listings-and-accept-applications", "creating-the-perfect-teacher-job-advert"))
    end

    it "sets cache expiry" do
      expect(response.headers["Cache-Control"]).to include("max-age=10800")
    end
  end
end
