require 'rails_helper'

RSpec.describe Subscription, type: :model do
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
end
