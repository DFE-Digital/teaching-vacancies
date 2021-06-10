require "rails_helper"

RSpec.describe PersistVacancyPageViewJob do
  let(:vacancy) { create(:vacancy, total_pageviews: 99) }

  it "increments the counter" do
    described_class.perform_now(vacancy.id)

    expect(vacancy.reload.total_pageviews).to eq(100)
  end
end
