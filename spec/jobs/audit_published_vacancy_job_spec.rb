require "rails_helper"

RSpec.describe AuditPublishedVacancyJob, type: :job do
  include ActiveJob::TestHelper

  let(:school) { create(:school) }
  let(:vacancy) { create(:vacancy) }
  subject(:job) { described_class.perform_later(vacancy.id) }

  before { vacancy.organisation_vacancies.create(organisation: school) }

  it "queues the job" do
    expect { job }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it "is in the default queue" do
    expect(job.queue_name).to eq("audit_published_vacancy")
  end

  it "creates an audit record" do
    expect { perform_enqueued_jobs { job } }.to change { AuditData.count }.by(1)
  end
end
