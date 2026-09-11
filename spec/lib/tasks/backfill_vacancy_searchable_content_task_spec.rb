require "rails_helper"

RSpec.describe "backfill_vacancy_searchable_content" do
  let(:school) { create(:school) }

  let(:school_vacancy) { create(:vacancy, organisations: [school]) }
  let(:expired_vacancy) { create(:vacancy, :expired, organisations: [school]) }

  before do
    school_vacancy.update_columns(searchable_content: nil)
    expired_vacancy.update_columns(searchable_content: nil)
  end

  it "backfills the searchable_content field" do
    expect {
      Rake::Task["backfill_vacancy_searchable_content"].execute
    }.to change { Vacancy.where(searchable_content: nil).count }.by(-1)
  end
end
