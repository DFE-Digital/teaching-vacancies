require 'rails_helper'

RSpec.describe SendDailyAlertEmailJob, type: :job do
  include ActiveJob::TestHelper

  subject(:job) { described_class.perform_later }

  let(:search_criteria) do
    {
      subject: 'English',
      working_patterns: ['full_time'],
      phases: ['primary', 'secondary']
    }.to_json
  end

  let!(:subscription) { create(:subscription, search_criteria: search_criteria, frequency: :daily) }
  let!(:vacancies) { create_list(:vacancy, 5, :published_slugged) }

  let(:mail) { double(:mail) }

  it 'queues the job' do
    expect { job }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  context 'with vacancies' do
    before do
      allow_any_instance_of(described_class).to receive(:vacancies_for_subscription) { vacancies }
    end

    it 'sends an email' do
      expect(AlertMailer).to receive(:daily_alert).with(subscription.id, vacancies.pluck(:id)) { mail }
      expect(mail).to receive(:deliver_later).with(queue: :email_daily_alerts) { ActionMailer::DeliveryJob.new }
      perform_enqueued_jobs { job }
    end

    context 'when a run exists' do
      let!(:run) { subscription.alert_runs.create(run_on: Time.zone.today) }

      it 'does not send another email' do
        expect(AlertMailer).to_not receive(:daily_alert)
        perform_enqueued_jobs { job }
      end
    end

    context 'with no vacancies' do
      before do
        allow_any_instance_of(described_class).to receive(:vacancies_for_subscription) { [] }
      end

      it 'does not send an email' do
        expect(AlertMailer).to_not receive(:daily_alert)
        perform_enqueued_jobs { job }
      end

      it 'does not create a run' do
        perform_enqueued_jobs { job }
        expect(subscription.alert_runs.count).to eq(0)
      end
    end
  end

  describe '#vacancies_for_subscription' do
    let(:job) { described_class.new }

    it 'limits the number of vacancies' do
      relation = Vacancy.none

      allow(subscription).to receive(:vacancies_for_range) { relation }
      expect(relation).to receive(:limit).with(500)

      job.vacancies_for_subscription(subscription)
    end
  end
end
