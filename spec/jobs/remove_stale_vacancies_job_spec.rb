require "rails_helper"

RSpec.describe RemoveStaleVacanciesJob, type: :job do
  include ActiveJob::TestHelper

  subject(:job) { described_class.perform_later }

  it "deletes all vacancies without a job title" do
    2.times { create(:vacancy) }
    2.times { create(:vacancy, job_title: nil) }
    expect { perform_enqueued_jobs { job } }.to change { Vacancy.count }.from(4).to(2)
  end
end
