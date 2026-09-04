require "rails_helper"

RSpec.describe "backfill_vacancy_geolocation" do
  let(:task_path) { "lib/tasks/backfill_vacancy_geolocation" }

  let(:school) { create(:school) }
  let(:trust) { create(:trust) }

  let(:school_vacancy) { create(:vacancy, organisations: [school]) }

  before do
    school_vacancy.update!(geolocation: nil)
    create(:vacancy, organisations: [trust])
  end

  it "backfills the geolocation field" do
    expect {
      Rake::Task["backfill_vacancy_geolocation"].execute
    }.to change { Vacancy.where(geolocation: nil).count }.by(-1)
  end
end
