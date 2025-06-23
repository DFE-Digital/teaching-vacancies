require "rails_helper"

RSpec.describe DisableInactiveProfilesJob do
  before do
    create(:jobseeker)
    create(:jobseeker_profile)
    create(:jobseeker_profile, jobseeker: build(:jobseeker, last_sign_in_at: 7.months.ago))
  end

  it "makes profiles over 6 months inactive" do
    expect { described_class.perform_now }.to change { JobseekerProfile.active.count }.by(-1)
    expect { perform_enqueued_jobs }.to change(ActionMailer::Base.deliveries, :count).by(1)
  end
end
