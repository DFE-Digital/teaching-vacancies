require 'rails_helper'

RSpec.describe PersistVacancyPageViewJob, type: :job do
  include ActiveJob::TestHelper

  let(:id) { SecureRandom.uuid }
  subject(:job) { described_class.perform_later(id) }

  it 'queues the job' do
    expect { job }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it 'is in the page view collector queue' do
    expect(job.queue_name).to eq('vacancy_statistics')
  end

  it 'executes perform' do
    vacancy_page_view = double(:vacancy_page_view)
    vacancy = double(:vacancy)
    allow(Vacancy).to receive(:find).with(id).and_return(vacancy)

    expect(VacancyPageView).to receive(:new).with(vacancy).and_return(vacancy_page_view)
    expect(vacancy_page_view).to receive(:persist!)

    perform_enqueued_jobs { job }
  end
end
