require "rails_helper"

RSpec.describe SendApplicationsReceivedYesterdayJob do
  # subject(:job) { described_class.perform_later }

  let!(:publisher) do
    create(:publisher,
           vacancies: create_list(:vacancy, 1,
                                  job_applications: create_list(:job_application, 1, :status_submitted, submitted_at: Date.yesterday)))
  end
  let(:message_delivery) { instance_double(ActionMailer::MessageDelivery) }

  it "sends applications received emails" do
    expect(Publishers::JobApplicationMailer)
      .to receive(:applications_received)
      .with(publisher, publisher.vacancies)
      .and_return(message_delivery)

    expect(message_delivery).to receive(:deliver_later)

    described_class.perform_now
  end
end
