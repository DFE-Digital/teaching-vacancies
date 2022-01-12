require "rails_helper"

RSpec.describe SendWeeklyAlertEmailJob do
  subject(:job) { described_class.perform_later }

  let(:search_criteria) do
    {
      subject: "English",
      working_patterns: %w[full_time],
      phases: %w[primary secondary],
    }
  end

  let!(:subscription) { create(:subscription, search_criteria: search_criteria, frequency: :weekly) }
  let!(:vacancies) { create_list(:vacancy, 5, :published_slugged) }

  let(:mail) { double(:mail) }

  context "with vacancies" do
    before do
      allow_any_instance_of(described_class).to receive(:vacancies_for_subscription) { vacancies }
      allow(DisableExpensiveJobs).to receive(:enabled?).and_return(false)
    end

    it "sends an email" do
      expect(Jobseekers::AlertMailer).to receive(:alert).with(subscription.id, vacancies.pluck(:id)) { mail }
      expect(mail).to receive(:deliver_later) { ActionMailer::MailDeliveryJob.new }
      perform_enqueued_jobs { job }
    end

    context "when a run exists" do
      let!(:run) { subscription.alert_runs.create(run_on: Date.current) }

      it "does not send another email" do
        expect(Jobseekers::AlertMailer).to_not receive(:alert)
        perform_enqueued_jobs { job }
      end
    end

    context "with no vacancies" do
      before do
        allow_any_instance_of(described_class).to receive(:vacancies_for_subscription) { [] }
      end

      it "does not send an email" do
        expect(Jobseekers::AlertMailer).to_not receive(:alert)
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

    it "gets weekly subscriptions" do
      expect(Subscription).to receive_message_chain(:active, :weekly).and_return(
        Subscription.where(active: true).where(frequency: :weekly),
      )
      job.subscriptions
    end
  end

  describe "#vacancies_for_subscription" do
    let(:job) { described_class.new }

    it "gets vacancies in the last week" do
      expect(subscription).to receive(:vacancies_for_range).with(1.week.ago.to_date, Date.current) { Vacancy.none }
      job.vacancies_for_subscription(subscription)
    end
  end
end
