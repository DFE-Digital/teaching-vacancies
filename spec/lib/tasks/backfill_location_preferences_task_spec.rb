require "rails_helper"

RSpec.describe "backfill_location_preferences" do
  include_context "rake"

  context "with a valid location" do
    let(:polygon) { create(:location_polygon) }

    before do
      create(:job_preferences, locations: build_list(:job_preferences_location, 1))
      create(:job_preferences, locations: build_list(:job_preferences_location, 1, name: polygon.name))

      JobPreferences::Location.update_all(uk_area: nil)
    end

    # rubocop:disable RSpec/NamedSubject
    it "updates the uk_area property for both polygon and non-polygon locations" do
      expect {
        subject.invoke
      }.to change { JobPreferences::Location.where(uk_area: nil).count }.by(-2)
    end
    # rubocop:enable RSpec/NamedSubject
  end
end
