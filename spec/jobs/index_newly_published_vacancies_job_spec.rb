require "rails_helper"

RSpec.describe IndexNewlyPublishedVacanciesJob do
  include Rails.application.routes.url_helpers

  before do
    allow(UpdateGoogleIndexQueueJob).to receive(:perform_later)
  end

  it "enqueues UpdateGoogleIndexQueueJob for each vacancy published today" do
    published_today_vacancy = create(:vacancy, :published, publish_on: Time.zone.today)
    create(:vacancy, :published, publish_on: Time.zone.today - 1.day)

    described_class.perform_now

    expect(UpdateGoogleIndexQueueJob).to have_received(:perform_later).with(job_url(published_today_vacancy))

    expect(UpdateGoogleIndexQueueJob).to have_received(:perform_later).exactly(1).times
  end
end
