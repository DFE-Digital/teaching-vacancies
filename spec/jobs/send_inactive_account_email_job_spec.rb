require "rails_helper"

RSpec.describe SendInactiveAccountEmailJob do
  subject(:job) { described_class.perform_later }

  let(:jobseeker) { create(:jobseeker, last_sign_in_at:) }
  let(:message_delivery) { instance_double(ActionMailer::MessageDelivery) }

  before { allow(DisableExpensiveJobs).to receive(:enabled?).and_return(false) }

  context "with inactive jobseeker for 5 years" do
    let(:last_sign_in_at) { 5.years.ago }

    it "sends inactive account emails" do
      expect(Jobseekers::AccountMailer)
        .to receive(:inactive_account)
        .with(jobseeker)
        .and_return(message_delivery)

      expect(message_delivery).to receive(:deliver_later)

      perform_enqueued_jobs { job }
    end
  end

  context "with active jobseeker" do
    let(:last_sign_in_at) { 2.days.ago }

    it "does not send inactive account emails" do
      expect(Jobseekers::AccountMailer)
        .not_to receive(:inactive_account)
        .with(jobseeker)

      perform_enqueued_jobs { job }
    end
  end
end
