require "rails_helper"

RSpec.describe CampaignSearchParamsMerger do
  subject { described_class.new(url_params, campaign_page) }

  let(:url_params) { { email_location: "London", email_jobrole: "Teacher", email_fulltime: "true" } }
  let(:campaign_page) {  CampaignPage["FAKE1+CAMPAIGN"] }

  describe "#initialize" do
    it "initializes with URL params and campaign page" do
      expect(subject).to be_an_instance_of(described_class)
    end
  end

  describe "#merged_params" do
    it "returns a hash of merged params with URL params taking precedence over campaign criteria" do
      expect(subject.merged_params).to include(location: "London", teaching_job_roles: ["Teacher"], working_patterns: ["full_time"])
    end

    it "adds a radius from the campaign criteria" do
      expect(subject.merged_params[:radius]).to eq(15)
    end

    context "when subjects and phases are present in the URL params" do
      let(:url_params) { { email_jobrole: "head_of_year_or_phase", email_subject: "math", email_phase: "primary" } }

      it "assigns subjects and phases from the URL params" do
        expect(subject.merged_params[:teaching_job_roles]).to eq(["head_of_year_or_phase"])
        expect(subject.merged_params[:subjects]).to eq(["math"])
        expect(subject.merged_params[:phases]).to eq(["primary"])
      end
    end

    context "when working pattern parameters are present in URL params" do
      let(:url_params) { { email_fulltime: "true", email_subject: "math", email_phase: "primary" } }

      it "extracts full_time from URL params into working_patterns" do
        expect(subject.merged_params[:working_patterns]).to contain_exactly("full_time")
      end
    end

    context "when ECT status is present in URL params" do
      let(:url_params) { { email_ECT: "true" } }

      it "maps email_ECT to ect_statuses" do
        expect(subject.merged_params[:ect_statuses]).to eq(["ect_suitable"])
      end
    end

    context "when URL params are absent" do
      let(:url_params) { { email_location: nil, email_jobrole: nil } }

      it "falls back to campaign criteria" do
        expect(subject.merged_params[:location]).to eq(nil)
        expect(subject.merged_params[:teaching_job_roles]).to eq(["teacher"])
      end
    end
  end
end
