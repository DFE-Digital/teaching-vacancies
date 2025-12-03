require "rails_helper"

RSpec.describe SendInactiveAccountEmailJob do
  let(:jobseeker) { create(:jobseeker, last_sign_in_at: last_sign_in_at) }
  let(:message_delivery) { instance_double(ActionMailer::MessageDelivery) }

  context "with inactive jobseeker for 6 years" do
    let(:last_sign_in_at) { 6.years.ago + 2.weeks }

    it "sends inactive account emails" do
      expect(Jobseekers::AccountMailer)
        .to receive(:inactive_account)
              .with(jobseeker)
              .and_return(message_delivery)

      expect(message_delivery).to receive(:deliver_later)

      described_class.perform_now
    end

    context "when email notifications are disabled", :disable_email_notifications do
      it "does not send emails" do
        expect(Jobseekers::AccountMailer)
          .not_to receive(:inactive_account)

        described_class.perform_now
      end
    end
  end

  context "with active jobseeker" do
    let(:last_sign_in_at) { 2.days.ago }

    it "does not send inactive account emails" do
      expect(Jobseekers::AccountMailer)
        .not_to receive(:inactive_account)

      described_class.perform_now
    end
  end
end
