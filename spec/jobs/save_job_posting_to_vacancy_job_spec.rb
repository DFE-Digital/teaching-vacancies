require "rails_helper"

RSpec.describe SaveJobPostingToVacancyJob, type: :job do
  include ActiveJob::TestHelper

  let(:job_posting) { instance_double("JobPosting") }
  let(:vacancy) { double(:vacancy, id: "some-uuid-1234") }
  let(:data) { { "@context" => "http://schema.org", "@type" => "JobPosting", "title" => "Science Teacher" } }
  let(:logger_double) { double(:logger).as_null_object }
  subject(:job) { described_class.perform_later(data) }

  before do
    allow(JobPosting).to receive(:new).with(data).and_return(job_posting)
    allow(job_posting).to receive(:to_vacancy).and_return(vacancy)
    allow(Rails).to receive(:logger).and_return(logger_double)
  end

  it "queues the job" do
    expect { job }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it "is in the seed vacancies from api queue" do
    expect(job.queue_name).to eq("seed_vacancies_from_api")
  end

  it "executes perform" do
    expect(vacancy).to receive(:save) { true }

    perform_enqueued_jobs { job }
  end

  it "logs the ID of the vacancy it created" do
    allow(vacancy).to receive(:save) { true }
    expect(logger_double).to receive(:info)
      .with("Saved vacancy from JobPosting. Vacancy ID: #{vacancy.id}")

    perform_enqueued_jobs { job }
  end

  context "when the vacancy fails to save" do
    let(:vacancy) { double(:vacancy, errors: double(messages: ["Education can’t be blank"])) }

    it "logs the errors" do
      allow(vacancy).to receive(:save) { false }
      expect(logger_double).to receive(:warn)
        .with('Failed to save vacancy from JobPosting: ["Education can’t be blank"]')

      perform_enqueued_jobs { job }
    end
  end
end
