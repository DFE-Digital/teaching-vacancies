require "rails_helper"

RSpec.describe "Vacancies" do
  describe "GET #index" do
    it "sets headers robots are asked to index but not to follow" do
      get jobs_path
      expect(response.headers["X-Robots-Tag"]).to eq("noarchive")
    end

    it "clamps to page 1 instead of raising when page is 0" do
      get jobs_path(page: 0)
      expect(response).to have_http_status(:ok)
    end

    it "clamps to page 1 instead of raising when page is negative" do
      get jobs_path(page: -1)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET #show" do
    let(:vacancy) { create(:vacancy) }

    context "with referrer" do
      let(:referrer_url) {  "https://example.com/some/path?utm=123" }

      it "tracks the view in Redis" do
        mock_redis = MockRedis.new
        allow(Redis).to receive(:new).and_return(mock_redis)

        redis_key = "vacancy_referrer_stats:#{vacancy.id}:example"

        perform_enqueued_jobs do
          get job_path(vacancy), params: {}, headers: { "Referer" => referrer_url }
        end
        expect(mock_redis.get(redis_key).to_i).to be > 0
      end
    end

    context "with utm campaign (e.g. job alert links)" do
      it "tracks the view" do
        expect { get job_path(vacancy), params: { utm_campaign: "job_alert" } }.to have_enqueued_job(TrackVacancyViewJob)
      end
    end

    context "without referrer" do
      it "doesnt track the job" do
        expect { get job_path(vacancy) }.not_to have_enqueued_job(TrackVacancyViewJob)
      end
    end
  end
end
