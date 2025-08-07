require "rails_helper"

RSpec.describe InactiveProfileWarningsJob do
  before do
    create(:jobseeker)
    create(:jobseeker_profile)
    create(:jobseeker_profile, :with_personal_details, jobseeker: build(:jobseeker, last_sign_in_at: 5.months.ago + 1.hour))
    create(:jobseeker_profile, jobseeker: build(:jobseeker, last_sign_in_at: 6.months.ago + 2.weeks + 1.hour))
  end

  it "sends a warning email to people at 5 months and 6 months - 2.weeks thresholds" do
    described_class.perform_now
    expect { perform_enqueued_jobs }.to change(ActionMailer::Base.deliveries, :count).by(2)
  end
end
