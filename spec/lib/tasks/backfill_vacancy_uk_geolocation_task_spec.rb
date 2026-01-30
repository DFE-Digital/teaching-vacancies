require "rails_helper"

RSpec.describe "backfill_vacancy_uk_geolocation" do
  include_context "rake"

  let(:school) { create(:school) }

  before do
    create(:vacancy, organisations: [school], uk_geolocation: nil)
  end

  # rubocop:disable RSpec/NamedSubject
  it "backfills the uk_geolocation field" do
    expect {
      subject.invoke
    }.to change { Vacancy.where(uk_geolocation: nil).count }.by(-1)
  end
  # rubocop:enable RSpec/NamedSubject
end
