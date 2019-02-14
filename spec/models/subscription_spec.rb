require 'rails_helper'

RSpec.describe Subscription, type: :model do
  it { should have_many(:alert_runs) }

  context 'validations' do
    context 'email' do
      it 'ensures an email is set' do
        subscription = Subscription.new

        expect(subscription.valid?).to eq(false)
        expect(subscription.errors.messages[:email]).to eq(['can\'t be blank'])
      end

      it 'ensures a valid email address is used' do
        subscription = Subscription.new email: 'inv@al@.id.email.com'

        expect(subscription.valid?).to eq(false)
        expect(subscription.errors.messages[:email]).to eq(['is not a valid email address'])
      end
    end

    context 'unique index' do
      it 'validates uniqueness of email, expires_on, frequency and search_criteria' do
        create(:subscription, email: 'jane@doe.com',
                              frequency: :daily)
        subscription = build(:subscription, email: 'jane@doe.com',
                                            frequency: :daily)

        expect(subscription.valid?).to eq(false)
        expect(subscription.errors.messages[:search_criteria]).to eq(['has already been taken'])
      end
    end
  end

  context 'scopes' do
    before(:each) do
      create_list(:subscription, 3, frequency: :daily)
      create_list(:subscription, 5, frequency: :daily, expires_on: Time.zone.yesterday)
      create_list(:subscription, 2, status: :trashed, frequency: :daily)
    end

    context 'active' do
      it 'retrieves all subscriptions with an active status' do
        expect(Subscription.active.count).to eq(8)
      end
    end

    context 'daily' do
      it 'retrieves all subscriptions with frequency set to :daily' do
        expect(Subscription.daily.count).to eq(10)
      end
    end

    context 'trashed' do
      it 'retrieves all subscriptions with status set to :trashed' do
        expect(Subscription.trashed.count).to eq(2)
      end
    end

    context 'ongoing' do
      it 'retrieves all valid active subscriptions' do
        expect(Subscription.ongoing.count).to eq(3)
      end
    end
  end

  it 'defaults the status to active' do
    subscription = create(:subscription, frequency: :daily)

    expect(subscription.status).to eq('active')
  end

  context 'reference' do
    it 'generates a reference if one is not set' do
      expect(SecureRandom).to receive(:hex).and_return('ABCDEF')
      subscription = create(:subscription, frequency: :daily)

      expect(subscription.reference).to eq('ABCDEF')
    end

    it 'does not generate a reference if one is set' do
      subscription = create(:subscription, reference: 'A-reference', frequency: :daily)

      expect(subscription.reference).to eq('A-reference')
    end
  end

  context 'token generation' do
    before do
      stub_const('SUBSCRIPTION_KEY_GENERATOR_SECRET', 'foo')
      stub_const('SUBSCRIPTION_KEY_GENERATOR_SALT', 'bar')
    end

    let(:subscription) { create(:subscription, frequency: :daily) }
    let(:token) { subscription.token }

    it 'generates a token' do
      expect(token).to_not be_nil
    end

    describe '#find_and_verify_by_token' do
      let(:result) { Subscription.find_and_verify_by_token(token) }

      it 'finds by token' do
        expect(result).to eq(subscription)
      end

      context 'when token is expired' do
        let(:token) do
          Timecop.travel(-3.days) { subscription.token }
        end

        it 'raises an error' do
          expect { result }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context 'when token is incorrect' do
        let(:token) { subscription.id }

        it 'raises an error' do
          expect { result }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end
  end

  context 'vacancies_for_range' do
    let(:subscription) do
      create(:subscription, frequency: :daily, search_criteria: { keyword: 'english' }.to_json)
    end

    let!(:old_matching_vacancies) do
      Timecop.freeze(2.days.ago) do
        create_list(:vacancy, 1, :published_slugged, publish_on: Time.zone.today, job_title: 'English Language')
      end
    end

    let!(:old_vacancies) do
      Timecop.freeze(2.days.ago) { create_list(:vacancy, 1, :published_slugged, publish_on: Time.zone.today) }
    end

    let!(:current_unmatching_vacancies) do
      Timecop.freeze(1.day.ago) { create_list(:vacancy, 3, :published_slugged, publish_on: Time.zone.today) }
    end

    let!(:current_matching_vacancies) do
      Timecop.freeze(1.day.ago) do
        create_list(:vacancy, 4, :published_slugged, publish_on: Time.zone.today, job_title: 'English Language')
      end
    end

    it 'returns the correct vacancies' do
      Vacancy.__elasticsearch__.client.indices.flush
      vacancies = subscription.vacancies_for_range(Time.zone.yesterday, Time.zone.today)
      expect(vacancies.pluck(:id)).to match_array(current_matching_vacancies.pluck(:id))
    end
  end

  describe 'alert_run_today?' do
    let(:subscription) { create(:subscription, frequency: :daily) }
    subject { subscription.alert_run_today? }

    context 'when an alert has run today' do
      before do
        subscription.alert_runs.find_or_create_by(run_on: Time.zone.today)
      end

      it { expect(subject).to eq(true) }
    end

    context 'when an alert ran yesterday' do
      before do
        subscription.alert_runs.find_or_create_by(run_on: Time.zone.yesterday)
      end

      it { expect(subject).to eq(false) }
    end

    context 'when an alert has never run' do
      it { expect(subject).to eq(false) }
    end
  end

  describe 'create_alert_run' do
    let(:subscription) { create(:subscription, frequency: :daily) }

    it 'creates a run' do
      subscription.create_alert_run

      expect(subscription.alert_runs.count).to eq(1)
      expect(subscription.alert_runs.first.run_on).to eq(Time.zone.today)
    end

    context 'if a run exists for today' do
      let!(:alert_run) { subscription.alert_runs.create(run_on: Time.zone.today) }

      it 'does not create another run' do
        subscription.create_alert_run

        expect(subscription.alert_runs.count).to eq(1)
        expect(subscription.alert_runs.first.id).to eq(alert_run.id)
      end
    end
  end
end
