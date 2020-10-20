require 'rails_helper'

RSpec.describe RefreshVacancyFacetsJob, type: :job do
  include ActiveJob::TestHelper

  subject(:job) { described_class.perform_later }

  it 'queues the job' do
    expect { job }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it 'is in the refresh_vacancy_facets queue' do
    expect(job.queue_name).to eq('refresh_vacancy_facets')
  end

  it 'invokes the service that refreshes the vacancy facets' do
    expect(VacancyFacets).to receive_message_chain(:new, :refresh)

    perform_enqueued_jobs { job }
  end
end
