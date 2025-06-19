require "rails_helper"

RSpec.describe DisableActiveProfilesWithoutNewFieldsJob do
  before do
    create(:jobseeker)
    create(:jobseeker_profile, :completed)
    create(:jobseeker_profile)
  end

  it "makes incomplete profiles inactive, and sends job seeker an email to that effect" do
    expect { described_class.perform_now }.to change { JobseekerProfile.active.count }.by(-1)
    expect { perform_enqueued_jobs }.to change(ActionMailer::Base.deliveries, :count).by(1)
  end
end
