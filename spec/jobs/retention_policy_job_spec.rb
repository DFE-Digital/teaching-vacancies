require "rails_helper"

RSpec.describe RetentionPolicyJob do
  let(:job) { described_class.new }

  describe ".threshold" do
    it { expect { job.threshold }.to raise_error("define thresold period in subclass") }
  end

  describe ".scopes" do
    subject(:scopes) { job.scopes.to_a }

    before do
      allow(job).to receive_messages(threshold:, "hard_delete?" => hard_delete?)
    end

    let(:threshold) { 2.days.ago }
    let(:over_the_threshold) { 3.days.ago }
    let(:today) { Time.zone.now }

    let(:drafts) { create_list(:job_application, 2, :status_draft, updated_at: over_the_threshold) }
    let(:submitteds) { create_list(:job_application, 2, :status_submitted, submitted_at: today) }
    let(:interviews) { create_list(:job_application, 2, :status_interviewing_with_pre_checks, submitted_at: over_the_threshold) }

    let(:self_disclosures) { interviews.map(&:self_disclosure) }
    let(:self_disclosure_requests) { interviews.map(&:self_disclosure_request) }
    let(:job_references) { interviews.map { |ja| ja.referees.first.job_reference } }
    let(:reference_requests) { interviews.map { |ja| ja.referees.first.reference_request } }
    let(:job_applications) { interviews }

    let(:expired_vacancy) { create(:vacancy, :expired) }
    let!(:draft_job_applications) { create_list(:job_application, 2, :status_draft, vacancy: expired_vacancy, updated_at: over_the_threshold) }

    let!(:feedbacks) { create_list(:feedback, 2, created_at: over_the_threshold) }

    context "when soft deleting" do
      let(:hard_delete?) { false }

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

      it "returns draft job applications for expired vacancy" do
        expect(scopes[5]).to match_array(draft_job_applications)
      end

      it "does not return feedback" do
        expect(scopes[6]).to be_nil
      end
    end

    context "when hard deleting" do
      let(:hard_delete?) { true }

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

      it "returns draft job applications for expired vacancy" do
        expect(scopes[5]).to match_array(draft_job_applications)
      end

      it "returns feedback" do
        expect(scopes[6]).to match_array(feedbacks)
      end
    end
  end
end
