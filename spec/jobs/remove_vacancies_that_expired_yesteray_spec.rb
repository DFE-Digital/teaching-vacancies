require "rails_helper"

RSpec.describe RemoveVacanciesThatExpiredYesterday, type: :job do
  include ActiveJob::TestHelper

  subject(:job) { described_class.perform_later }

  it "queues the job" do
    expect { job }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it "is in the correct queue" do
    expect(job.queue_name).to eq("remove_vacancies_that_expired_yesterday")
  end

  it "invokes Vacancy#remove_vacancies_that_expired_yesterday!" do
    expect(Vacancy).to receive(:remove_vacancies_that_expired_yesterday!)
    perform_enqueued_jobs { job }
  end
end
