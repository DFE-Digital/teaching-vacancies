require "rails_helper"

RSpec.describe SelfDisclosureRequest do
  describe "validation" do
    subject { create(:self_disclosure_request) }

    it { is_expected.to validate_uniqueness_of(:job_application_id).case_insensitive }
  end

  describe "#create_for!" do
    let(:job_application) { create(:job_application) }

    context "with create call" do
      before { described_class.create_for!(job_application) }

      let(:request) { job_application.self_disclosure_request }

      it { expect(request.self_disclosure).to be_nil }
      it { expect(request.status).to eq("manual") }
    end

    it "does not send the notification email" do
      expect {  described_class.create_for!(job_application) }
        .not_to have_enqueued_email(Jobseekers::JobApplicationMailer, :self_disclosure)
        .with(job_application)
    end
  end

  describe "#create_and_notify!" do
    let(:job_application) { create(:job_application) }

    context "with create call" do
      before { described_class.create_and_notify!(job_application) }

      let(:request) { job_application.self_disclosure_request }

      it { expect(request.self_disclosure).to be_present }
      it { expect(request.status).to eq("sent") }
    end
  end

  describe ".pending?" do
    subject { described_class.new(status:).pending? }

    %i[manual sent].each do |status|
      context "when #{status}" do
        let(:status) { status }

        it { is_expected.to be true }
      end
    end

    %i[received_off_service received].each do |status|
      context "when #{status}" do
        let(:status) { status }

        it { is_expected.to be false }
      end
    end
  end
end
