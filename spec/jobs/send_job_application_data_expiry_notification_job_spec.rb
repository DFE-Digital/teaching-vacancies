require "rails_helper"

RSpec.describe SendJobApplicationDataExpiryNotificationJob do
  let(:notification) { instance_double(Publishers::JobApplicationDataExpiryNotification) }
  let(:organisation) { create(:school) }
  let(:publisher) { create(:publisher, organisation_publishers_attributes: [{ organisation: organisation }]) }
  let!(:vacancy_with_two_weeks_to_data_expiry) { create(:vacancy, expires_at: 351.days.ago, publisher: publisher, organisation_vacancies_attributes: [{ organisation: organisation }]) }
  let!(:vacancy) { create(:vacancy, expires_at: 1.day.ago, publisher: publisher, organisation_vacancies_attributes: [{ organisation: organisation }]) }

  # before do
  #   allow(DisableExpensiveJobs).to receive(:enabled?).and_return(false)
  # end

  it "sends notifications" do
    expect(Publishers::JobApplicationDataExpiryNotification).to receive(:with).with(vacancy: vacancy_with_two_weeks_to_data_expiry, publisher: publisher).and_return(notification)
    expect(Publishers::JobApplicationDataExpiryNotification).not_to receive(:with).with(vacancy: vacancy, publisher: publisher)
    expect(notification).to receive(:deliver).with(publisher)
    described_class.perform_now
  end
end
