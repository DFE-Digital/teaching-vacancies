require "rails_helper"

RSpec.describe PersistVacancyGetMoreInfoClickJob, type: :job do
  subject(:job) { described_class.perform_later(vacancy.id) }

  let(:vacancy) { create(:vacancy, total_get_more_info_clicks: 66) }

  it "increments the counter" do
    perform_enqueued_jobs { job }

    expect(vacancy.reload.total_get_more_info_clicks).to eq(67)
  end
end
