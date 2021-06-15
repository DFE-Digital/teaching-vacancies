require "rails_helper"

RSpec.describe SendJobApplicationDataExpiryNotificationJob do
  subject(:job) { described_class.perform }

  let(:organisation) { create(:school) }
  let(:publisher) { create(:publisher) }
  let(:two_weeks_less_than_a_year_ago) { Time.zone.now - (1.year - 2.weeks) }
  let(:vacancy) { create(:vacancy, expires_at: two_weeks_less_than_a_year_ago, publisher: publisher, organisation_vacancies_attributes: [{ organisation: organisation }]) }

  let(:notification) { double(:notification) }

  before do
    allow(DisableExpensiveJobs).to receive(:enabled?).and_return(false)
  end

  it "sends an email" do
    expect(Publishers::JobApplicationDataExpiryNotification).to receive(:with).with(vacancy: vacancy, publisher: publisher) { notification }
    expect(notification).to receive(:deliver)
  end
end
