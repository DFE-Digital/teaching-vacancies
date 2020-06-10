require 'rails_helper'

RSpec.describe ExportDsiUsersToBigQueryJob, type: :job do
  include ActiveJob::TestHelper

  subject(:job) { described_class.perform_later }

  it 'queues the job' do
    expect { job }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it 'is in the export_users queue' do
    expect(job.queue_name).to eq('export_users')
  end

  it 'invokes the libs to export users and approvers to big query' do
    export_dsi_users_to_big_query = double(:export_dsi_users_to_big_query)
    expect(ExportDsiUsersToBigQuery).to receive(:new) { export_dsi_users_to_big_query }
    expect(export_dsi_users_to_big_query).to receive(:run!)

    export_dsi_approvers_to_big_query = double(:export_dsi_approvers_to_big_query)
    expect(ExportDsiApproversToBigQuery).to receive(:new) { export_dsi_approvers_to_big_query }
    expect(export_dsi_approvers_to_big_query).to receive(:run!)

    perform_enqueued_jobs { job }
  end
end
