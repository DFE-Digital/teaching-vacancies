require "rails_helper"

RSpec.describe SendDailyAlertEmailJob, type: :job do
  include ActiveJob::TestHelper

  subject(:job) { described_class.perform_later }

  let(:search_criteria) do
    {
      subject: "English",
      working_patterns: %w[full_time],
      phases: %w[primary secondary],
    }.to_json
  end

  let!(:subscription) { create(:subscription, search_criteria: search_criteria, frequency: :daily) }
  let!(:vacancies) { create_list(:vacancy, 5, :published_slugged) }

  let(:mail) { double(:mail) }

  it "queues the job" do
    expect { job }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it "is in the queue_daily_alerts queue" do
    expect(job.queue_name).to eq("queue_daily_alerts")
  end

  context "with vacancies" do
    before do
      allow_any_instance_of(described_class).to receive(:vacancies_for_subscription) { vacancies }
      allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("production"))
    end

    it "sends an email" do
      expect(AlertMailer).to receive(:alert).with(subscription.id, vacancies.pluck(:id)) { mail }
      expect(mail).to receive(:deliver_later).with(queue: :email_alerts) { ActionMailer::DeliveryJob.new }
      perform_enqueued_jobs { job }
    end

    context "when a run exists" do
      let!(:run) { subscription.alert_runs.create(run_on: Date.current) }

      it "does not send another email" do
        expect(AlertMailer).to_not receive(:alert)
        perform_enqueued_jobs { job }
      end
    end

    context "with no vacancies" do
      before do
        allow_any_instance_of(described_class).to receive(:vacancies_for_subscription) { [] }
      end

      it "does not send an email" do
        expect(AlertMailer).to_not receive(:alert)
        perform_enqueued_jobs { job }
      end

      it "does not create a run" do
        perform_enqueued_jobs { job }
        expect(subscription.alert_runs.count).to eq(0)
      end
    end
  end

  describe "#subscriptions" do
    let(:job) { described_class.new }

    it "gets active daily subscriptions" do
      expect(Subscription).to receive_message_chain(:active, :daily).and_return(
        Subscription.where(active: true).where(frequency: :daily),
      )
      job.subscriptions
    end
  end

  describe "#vacancies_for_subscription" do
    let(:job) { described_class.new }

    it "gets vacancies in the last day" do
      expect(subscription).to receive(:vacancies_for_range).with(Time.zone.yesterday, Date.current) { Vacancy.none }
      job.vacancies_for_subscription(subscription)
    end

    it "limits the number of vacancies" do
      relation = Vacancy.none

      allow(subscription).to receive(:vacancies_for_range) { relation }
      expect(relation).to receive(:limit).with(500)

      job.vacancies_for_subscription(subscription)
    end
  end
end
