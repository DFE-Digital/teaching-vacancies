require "rails_helper"

RSpec.describe "backfill_uk_area", :perform_enqueued do
  include ActiveJob::TestHelper

  include_context "rake"

  context "with a geopoint subscription" do
    before do
      create(:subscription, :with_some_criteria, uk_geopoint: nil)
    end

    # rubocop:disable RSpec/NamedSubject
    it "updates the uk_geopoint property" do
      expect {
        subject.invoke
      }.to change { Subscription.where(uk_geopoint: nil).count }.by(-1)
    end
    # rubocop:enable RSpec/NamedSubject
  end

  context "with a polygon property" do
    before do
      create(:location_polygon, name: "london")
      create(:subscription, :with_some_criteria, uk_area: nil, location: "london")
    end

    # rubocop:disable RSpec/NamedSubject
    it "updates the uk_area property" do
      expect {
        subject.invoke
      }.to change { Subscription.where(uk_area: nil).count }.by(-1)
    end
    # rubocop:enable RSpec/NamedSubject
  end
end
