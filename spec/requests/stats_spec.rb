require "rails_helper"

RSpec.describe "Teaching Vacancies stats", type: :request do
  context "returns a JSON of useful information about the app" do
    context "default usage" do
      it "includes all audited information" do
        job = create(:vacancy)
        6.times { Auditor::Audit.new(nil, "dfe-sign-in.authentication.success", "sample").log_without_association }
        3.times { Auditor::Audit.new(nil, "dfe-sign-in.authorisation.success", "sample").log_without_association }
        2.times { Auditor::Audit.new(nil, "dfe-sign-in.authorisation.failure", "sample").log_without_association }
        Auditor::Audit.new(job, "vacancy.publish", "sample-id").log

        get stats_path, headers: { "CONTENT_TYPE" => "application/json", "ACCEPT" => "application/json" }

        json = JSON.parse(response.body)["teaching_jobs"]["summary"]
        expect(json["dfe-sign-in.authentication.success"]).to eq(6)
        expect(json["dfe-sign-in.authorisation.success"]).to eq(3)
        expect(json["dfe-sign-in.authorisation.failure"]).to eq(2)
        expect(json["vacancy.publish"]).to eq(1)
      end

      it "returns an ok http code" do
        get stats_path, headers: { "CONTENT_TYPE" => "application/json", "ACCEPT" => "application/json" }

        expect(response).to have_http_status(:ok)
      end

      it "includes job alert stats" do
        subscription = create(:subscription)
        _sent_alert_runs = create_list(:alert_run, 2, status: :sent, subscription: subscription)

        get stats_path, headers: { "CONTENT_TYPE" => "application/json", "ACCEPT" => "application/json" }

        json = JSON.parse(response.body)["teaching_jobs"]["summary"]
        expect(json["job_alert.sent"]).to eq(2)
      end
    end
  end
end
