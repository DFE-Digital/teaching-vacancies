require "rails_helper"

RSpec.describe RefreshMarkersJob do
  let!(:vacancy) { create(:vacancy, :expires_tomorrow) }
  let!(:expired_vacancy) { create(:vacancy, :expired_yesterday) }

  it "refreses markers" do
    described_class.perform_now
    expect(expired_vacancy.markers).to be_blank
    expect(vacancy.markers).to be_present
  end
end
