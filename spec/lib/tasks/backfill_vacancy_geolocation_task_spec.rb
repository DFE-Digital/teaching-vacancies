require "rails_helper"

RSpec.describe "backfill_vacancy_geolocation" do
  include_context "rake"

  let(:school) { create(:school) }
  let(:trust) { create(:trust) }

  before do
    create(:vacancy, organisations: [school], geolocation: nil)
    create(:vacancy, organisations: [trust], geolocation: nil)
  end

  # rubocop:disable RSpec/NamedSubject
  it "backfills the geolocation field" do
    expect {
      subject.invoke
    }.to change { Vacancy.where(geolocation: nil).count }.by(-1)
  end
  # rubocop:enable RSpec/NamedSubject
end
