require "rails_helper"

RSpec.describe AlertMailerJob do
  let(:school) { create(:school) }
  let!(:vacancies) { create_list(:vacancy, 5, organisations: [school]) }
  let(:subscription) { create(:daily_subscription) }
  let(:alert_run) { create(:alert_run, subscription:) }
  let(:job) { Jobseekers::AlertMailer.alert(subscription.id, vacancies.pluck(:id)).deliver_later! }

  it "creates a run" do
    job_id = "ABC1234"
    allow_any_instance_of(AlertMailerJob).to receive(:provider_job_id) { job_id }
    job
    expect(subscription.alert_runs.count).to eq(1)
    expect(subscription.alert_runs.first.job_id).to eq(job_id)
    expect(subscription.alert_runs.first.run_on).to eq(Date.current)
  end

  it "only creates one run" do
    job_id = "ABC1234"
    allow_any_instance_of(AlertMailerJob).to receive(:provider_job_id) { job_id }
    4.times { job }
    expect(subscription.alert_runs.count).to eq(1)
  end

  it "creates the run before enqueing" do
    # This is important as we have encountered a race condition where sometimes
    # the run does not exist when the job has started running
    allow_any_instance_of(AlertMailerJob).to receive(:subscription) { subscription }
    allow_any_instance_of(AlertMailerJob).to receive(:alert_run) { alert_run }

    expect(subscription).to receive(:create_alert_run).ordered
    expect(AlertMailerJob.queue_adapter).to receive(:enqueue).ordered
    job
  end

  it "adds the job ID after enqueuing" do
    job_id = "ABC1234"
    allow_any_instance_of(AlertMailerJob).to receive(:provider_job_id) { job_id }

    allow_any_instance_of(AlertMailerJob).to receive(:subscription) { subscription }
    expect(AlertMailerJob.queue_adapter).to receive(:enqueue).twice.ordered
    expect(subscription).to receive(:alert_run_today) { alert_run }
    expect(alert_run).to receive(:update).with(job_id:).ordered
    job
  end

  context "if the job has not expired" do
    let!(:alert_run) { create(:alert_run, subscription:) }

    it "delivers the mail" do
      expect { perform_enqueued_jobs { job } }.to change { delivered_emails.count }.by(1)
    end

    it "updates the alert run" do
      expect { perform_enqueued_jobs { job } }.to change { subscription.alert_run_today.status }.to("sent")
    end
  end

  context "if the job has expired" do
    let!(:alert_run) { create(:alert_run, subscription:, created_at: Time.current - 5.hours) }

    it "does not deliver the mail" do
      expect { perform_enqueued_jobs { job } }.to change { delivered_emails.count }.by(0)
    end
  end

  context "if the job has already been run" do
    let!(:alert_run) { create(:alert_run, subscription:, status: :sent) }

    it "does not deliver the mail" do
      expect { perform_enqueued_jobs { job } }.to change { delivered_emails.count }.by(0)
    end
  end
end
