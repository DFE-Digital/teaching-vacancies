require "rails_helper"

RSpec.describe RemoveStaleVacanciesJob, type: :job do
  include ActiveJob::TestHelper

  subject(:job) { described_class.perform_later }

  it "queues the job" do
    expect { job }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it "is in the clear_emergency_login_keys queue" do
    expect(job.queue_name).to eq("remove_stale_vacancies")
  end

  it "deletes all vacancies without a job title" do
    2.times { create(:vacancy) }
    2.times { create(:vacancy, job_title: nil) }
    expect { perform_enqueued_jobs { job } }.to change { Vacancy.all.size }.from(4).to(2)
  end
end
