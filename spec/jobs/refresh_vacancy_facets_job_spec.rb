require "rails_helper"

RSpec.describe RefreshVacancyFacetsJob, type: :job do
  include ActiveJob::TestHelper

  subject(:job) { described_class.perform_later }

  it "invokes the service that refreshes the vacancy facets" do
    expect(VacancyFacets).to receive_message_chain(:new, :refresh)

    perform_enqueued_jobs { job }
  end
end
