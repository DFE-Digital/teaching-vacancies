require "rails_helper"

RSpec.describe DeleteJobseekersWithIncorrectEmailsJob, type: :job do
  before do
    allow(Notifications::Client).to receive(:new).and_return(notify_client_mock)
    allow(notify_client_mock)
      .to receive(:get_notifications).with({ template_type: "email", status: "failure" })
                                     .and_return(notify_notifications_mock)
    allow(notify_notifications_mock).to receive(:collection).and_return(notify_api_response)
    allow(notify_client_mock)
      .to receive(:get_notifications).with({ template_type: "email", status: "failure", older_than: "last-email" })
                                     .and_return(double("no notifications", collection: []))
  end

  let(:jobseekers) do
    [
      create(:jobseeker, confirmed_at: nil),
      create(:jobseeker, confirmed_at: nil),
      create(:jobseeker),
    ]
  end
  let(:notify_client_mock) { instance_double(Notifications::Client) }
  let(:notify_notifications_mock) { double("notifications") }
  let(:notify_api_response) do
    [
      double("response", email_address: jobseekers.first.email, id: "email-1"),
      double("response", email_address: jobseekers.last.email, id: "last-email"),
    ]
  end

  it "only deletes an unconfirmed jobseeker with a bouncing email" do
    expect { described_class.perform_now }.to change(Jobseeker, :count).by(-1)
  end
end
