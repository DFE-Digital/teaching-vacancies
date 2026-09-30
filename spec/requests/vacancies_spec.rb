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

      it "tracks the view" do
        perform_enqueued_jobs do
          get job_path(vacancy), params: {}, headers: { "Referer" => referrer_url }
        end
        expect(VacancyAnalytics.find_by!(vacancy_id: vacancy.id).referrer_counts.symbolize_keys).to eq({ example: 1 })
      end
    end

    context "with utm campaign (e.g. job alert links)" do
      before do
        get job_path(vacancy), params: { utm_campaign: "job_alert" }
      end

      it "tracks the view" do
        expect(VacancyAnalytics.find_by!(vacancy_id: vacancy.id).referrer_counts.symbolize_keys).to eq({ direct: 1 })
      end
    end

    context "without referrer" do
      before do
        get job_path(vacancy)
      end

      it "doesnt track the job" do
        expect(VacancyAnalytics.find_by(vacancy_id: vacancy.id)).to be_nil
      end
    end
  end

  describe "GET #apply" do
    let(:vacancy) { create(:vacancy, :apply_via_website, external_application_clicks: 2) }

    it "increments the application click count and redirects to the application website" do
      expect { get apply_job_path(vacancy) }
        .to change { vacancy.reload.external_application_clicks }.from(2).to(3)

      expect(response).to redirect_to(vacancy.application_link)
    end

    it "does not count clicks for an expired vacancy" do
      vacancy.update!(expires_at: 1.day.ago)

      expect { get apply_job_path(vacancy) }
        .to(not_change { vacancy.reload.external_application_clicks })

      expect(response).to have_http_status(:not_found)
    end

    it "does not count clicks when there is no application link" do
      vacancy.update!(application_link: nil)

      expect { get apply_job_path(vacancy) }
        .to(not_change { vacancy.reload.external_application_clicks })

      expect(response).to have_http_status(:not_found)
    end

    context "when a signed-in jobseeker is in the TRN variant" do
      let(:jobseeker) { create(:jobseeker) }
      let(:vacancy) { create(:vacancy, :apply_via_website, job_roles: %w[teacher], external_application_clicks: 2) }

      before do
        sign_in(jobseeker, scope: :jobseeker)
        use_ab_test jobseeker, :trn_on_apply, :trn
      end

      after { sign_out(jobseeker) }

      it "redirects to the TRN interstitial without counting the click" do
        expect { get apply_job_path(vacancy) }
          .to(not_change { vacancy.reload.external_application_clicks })

        expect(response).to redirect_to(trn_interstitial_job_path(vacancy.id))
      end

      it "counts the click and redirects to the application website once the jobseeker has been prompted" do
        expect { get apply_job_path(vacancy, trn_prompted: true) }
          .to change { vacancy.reload.external_application_clicks }.from(2).to(3)

        expect(response).to redirect_to(vacancy.application_link)
      end

      context "when the vacancy is not for a teaching or middle leader role" do
        let(:vacancy) { create(:vacancy, :apply_via_website, :it_support) }

        it "redirects to the application website" do
          get apply_job_path(vacancy)

          expect(response).to redirect_to(vacancy.application_link)
        end
      end
    end
  end

  describe "GET #trn_interstitial" do
    context "when the vacancy takes applications through a website" do
      let(:vacancy) { create(:vacancy, :apply_via_website) }

      it "lets the jobseeker skip to the click-counting apply action" do
        get trn_interstitial_job_path(vacancy.id)

        expect(response.body).to include(%(href="#{apply_job_path(vacancy, trn_prompted: true)}"))
      end
    end

    context "when the vacancy takes job applications" do
      let(:vacancy) { create(:vacancy) }

      it "lets the jobseeker skip to the new job application page" do
        get trn_interstitial_job_path(vacancy.id)

        expect(response.body).to include(%(href="#{new_jobseekers_job_job_application_path(vacancy.id)}"))
      end
    end
  end

  describe "POST #send_trn" do
    let(:params) { { job_application: { teacher_reference_number: "1234567" } } }

    context "when the vacancy takes applications through a website" do
      let(:vacancy) { create(:vacancy, :apply_via_website) }

      it "redirects through the click-counting apply action" do
        post send_trn_job_path(vacancy.id), params: params

        expect(response).to redirect_to(apply_job_path(vacancy, trn_prompted: true))
      end
    end

    context "when the vacancy takes job applications" do
      let(:vacancy) { create(:vacancy) }

      it "redirects to the new job application page" do
        post send_trn_job_path(vacancy.id), params: params

        expect(response).to redirect_to(new_jobseekers_job_job_application_path(vacancy.id))
      end
    end
  end
end
