require "rails_helper"

RSpec.describe PersistVacancyPageViewJob, type: :job do
  include ActiveJob::TestHelper

  subject(:job) { described_class.perform_later(vacancy.id) }

  let(:vacancy) { create(:vacancy, total_pageviews: 99) }

  it "increments the counter" do
    perform_enqueued_jobs { job }

    expect(vacancy.reload.total_pageviews).to eq(100)
  end
end
