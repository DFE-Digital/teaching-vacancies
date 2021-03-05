require "rails_helper"

RSpec.describe UpdateAlgoliaIndex, type: :job do
  subject(:job) { described_class.perform_later }

  it "invokes Vacancy#update_index!" do
    expect(Vacancy).to receive(:update_index!)
    perform_enqueued_jobs { job }
  end
end
