require 'rails_helper'

RSpec.describe SaveJobPostingToVacancyJob, type: :job do
  include ActiveJob::TestHelper

  let(:job_posting) { instance_double('JobPosting') }
  let(:vacancy) { double(:vacancy) }
  let(:data) { { '@context' => 'http://schema.org', '@type' => 'JobPosting', 'title' => 'Science Teacher' } }
  subject(:job) { described_class.perform_later(data) }

  before do
    allow(JobPosting).to receive(:new).with(data).and_return(job_posting)
    allow(job_posting).to receive(:to_vacancy).and_return(vacancy)
  end

  it 'queues the job' do
    expect { job }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it 'is in the seed vacancies from api queue' do
    expect(job.queue_name).to eq('seed_vacancies_from_api')
  end

  it 'executes perform' do
    expect(vacancy).to receive(:save) { true }

    perform_enqueued_jobs { job }
  end

  context 'when the vacancy fails to save' do
    let(:vacancy) { double(:vacancy, errors: double(messages: ['Education can’t be blank'])) }

    it 'logs the errors' do
      allow(vacancy).to receive(:save) { false }
      expect(Rails.logger).to receive(:warn)
        .with('Failed to save vacancy from JobPosting: ["Education can’t be blank"]')

      perform_enqueued_jobs { job }
    end
  end
end
