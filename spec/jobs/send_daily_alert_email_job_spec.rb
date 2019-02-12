require 'rails_helper'

RSpec.describe SendDailyAlertEmailJob, type: :job do
  include ActiveJob::TestHelper

  subject(:job) { described_class.perform_later }

  let!(:subscription) { create(:subscription, frequency: :daily) }
  let!(:vacancies) { create_list(:vacancy, 5, :published_slugged) }

  let(:mail) { double(:mail) }

  it 'queues the job' do
    expect { job }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  context 'when a subscription is ongoing' do
    before do
      allow(Subscription).to receive(:ongoing) { [subscription] }
    end

    context 'with vacancies' do
      before do
        allow_any_instance_of(described_class).to receive(:vacancies_for_subscription) { vacancies }
      end

      it 'sends an email' do
        expect(AlertMailer).to receive(:daily_alert).with(subscription.id, vacancies.pluck(:id)) { mail }
        expect(mail).to receive(:deliver_later)
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
    end
  end

  context 'when a subscription is not ongoing' do
    before do
      allow(Subscription).to receive(:ongoing) { [] }
    end

    it 'does not send an email' do
      expect(AlertMailer).to_not receive(:daily_alert)
      perform_enqueued_jobs { job }
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
