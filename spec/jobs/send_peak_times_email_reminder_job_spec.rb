require "rails_helper"

RSpec.describe SendPeakTimesEmailReminderJob do
  subject(:job) { described_class.perform_later }

  let(:jobseeker) { create(:jobseeker, :with_personal_details) }

  describe "#perform" do
    let(:mail) { instance_double(ActionMailer::MessageDelivery) }

    before do
      allow(Jobseekers::PeakTimesMailer).to receive(:reminder).with(jobseeker.id) { mail }
    end

    it "enqueues mail sending job" do
      expect(Jobseekers::PeakTimesMailer).to receive(:reminder).with(jobseeker.id)
      expect(mail).to receive(:deliver_later)
      perform_enqueued_jobs { job }
    end
  end
end
