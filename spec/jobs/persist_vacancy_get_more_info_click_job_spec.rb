require "rails_helper"

RSpec.describe PersistVacancyGetMoreInfoClickJob do
  let(:vacancy) { create(:vacancy, total_get_more_info_clicks: 66) }

  it "increments the counter" do
    described_class.perform_now(vacancy.id)

    expect(vacancy.reload.total_get_more_info_clicks).to eq(67)
  end
end
