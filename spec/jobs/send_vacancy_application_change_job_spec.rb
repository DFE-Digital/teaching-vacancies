require "rails_helper"

RSpec.describe SendVacancyApplicationChangeJob do
  subject(:job) { described_class.perform_later }

  describe "#perform" do
    let(:mail) { instance_double(ActionMailer::MessageDelivery) }

    before do
      allow(Publishers::VacancyChangeMailer).to receive(:notify).with(vacancy:) { mail }
    end

    context "when vacancy created within the last 18 months" do
      let(:vacancy) { create(:vacancy, :with_application_form, created_at: 17.months.ago) }

      it "enqueues mail sending job" do
        expect(Publishers::VacancyChangeMailer).to receive(:notify).with(vacancy:)
        expect(mail).to receive(:deliver_later)
        perform_enqueued_jobs { job }
      end
    end

    context "when vacancy older than 18 months" do
      let(:vacancy) { create(:vacancy, :with_application_form, created_at: 19.months.ago) }

      it "does nothing" do
        expect(Publishers::VacancyChangeMailer).not_to receive(:notify).with(vacancy:)
        perform_enqueued_jobs { job }
      end
    end
  end
end
