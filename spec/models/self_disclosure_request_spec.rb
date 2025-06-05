require "rails_helper"

RSpec.describe SelfDisclosureRequest do
  describe "validation" do
    subject { create(:self_disclosure_request) }

    it { is_expected.to validate_uniqueness_of(:job_application_id).case_insensitive }
  end

  describe "#.create_all!" do
    let(:requests) { described_class.create_all!(job_applications) }
    let(:job_application) { create(:job_application) }
    let(:job_applications) { [job_application] }

    it { expect(requests.count).to eq(job_applications.count) }
    it { expect(requests.first.job_application).to eq(job_application) }
    it { expect(requests.first.self_disclosure).to be_nil }
    it { expect(requests.first.status).to eq("manual") }

    it "does not send the notification email" do
      expect { requests }
        .not_to have_enqueued_email(Jobseekers::JobApplicationMailer, :declarations)
        .with(job_application)
    end
  end

  describe "#.create_and_notify_all!" do
    let(:requests) { described_class.create_and_notify_all!(job_applications) }
    let(:job_application) { create(:job_application) }
    let(:job_applications) { [job_application] }

    it { expect(requests.count).to eq(job_applications.count) }
    it { expect(requests.first.job_application).to eq(job_application) }
    it { expect(requests.first.self_disclosure).to be_present }
    it { expect(requests.first.status).to eq("sent") }

    it "sends the notification email" do
      expect { requests }
        .to have_enqueued_email(Jobseekers::JobApplicationMailer, :declarations)
        .with(job_application)
    end
  end

  describe ".completed?" do
    subject { described_class.new(status:).completed? }

    %i[manual sent].each do |status|
      context "when #{status}" do
        let(:status) { status }

        it { is_expected.to be false }
      end
    end

    %i[manually_completed received].each do |status|
      context "when #{status}" do
        let(:status) { status }

        it { is_expected.to be true }
      end
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

    %i[manually_completed received].each do |status|
      context "when #{status}" do
        let(:status) { status }

        it { is_expected.to be false }
      end
    end
  end
end
