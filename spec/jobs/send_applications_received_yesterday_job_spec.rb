require "rails_helper"

RSpec.describe SendApplicationsReceivedYesterdayJob do
  subject(:job) { described_class.perform_later }

  let(:publisher) { create(:publisher) }
  let(:message_delivery) { instance_double(ActionMailer::MessageDelivery) }

  before { expect(Publisher).to receive_message_chain(:distinct, :joins, :where).and_return([publisher]) }

  it "sends applications received emails" do
    expect(Publishers::JobApplicationMailer)
      .to receive(:applications_received)
      .with(publisher:)
      .and_return(message_delivery)

    expect(message_delivery).to receive(:deliver_later)

    perform_enqueued_jobs { job }
  end
end
