require "rails_helper"

RSpec.describe RetentionPolicyJob do
  let(:job) { described_class.new }
  let(:drafts) { create_list(:job_application, 2, :status_draft) }
  let(:submitteds) { create_list(:job_application, 2, :status_submitted, submitted_at: Time.zone.now) }
  let(:interviews) { create_list(:job_application, 2, :status_interviewing_with_pre_checks, submitted_at: 3.days.ago) }
  let(:self_disclosures) { interviews.map(&:self_disclosure) }
  let(:self_disclosure_requests) { interviews.map(&:self_disclosure_request) }
  let(:job_references) { interviews.map { |ja| ja.referees.first.job_reference } }
  let(:reference_requests) { interviews.map { |ja| ja.referees.first.reference_request } }
  let(:job_applications) { interviews }

  before do
    allow(job).to receive(:threshold).and_return(threshold)
  end

  describe ".scopes" do
    subject(:scopes) { job.scopes.to_a }

    let(:threshold) { 2.days.ago }

    it "returns self-disclosures" do
      expect(scopes[0]).to match_array(self_disclosures)
    end

    it "returns self-disclosure requests" do
      expect(scopes[1]).to match_array(self_disclosure_requests)
    end

    it "returns job references" do
      expect(scopes[2]).to match_array(job_references)
    end

    it "returns reference requests" do
      expect(scopes[3]).to match_array(reference_requests)
    end

    it "returns job applications" do
      expect(scopes[4]).to match_array(job_applications)
    end
  end
end
