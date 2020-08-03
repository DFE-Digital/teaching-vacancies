require 'rails_helper'

RSpec.describe HiringStaff::VacancyFilter do
  let(:user) { create :user }
  let(:school_group) { create :school_group }
  let(:managed_organisations) { 'school_group' }
  let(:managed_school_urns) { ['1234', '5678'] }
  let!(:user_preference) { create :user_preference, user: user, school_group: school_group,
    managed_organisations: managed_organisations, managed_school_urns: managed_school_urns
  }

  subject { described_class.new(user, school_group) }

  describe '.initialize' do
    it 'sets the managed_organisations from user_preference' do
      expect(subject.managed_organisations).to eq managed_organisations
    end

    it 'sets the managed_school_urns from user_preference' do
      expect(subject.managed_school_urns).to eq managed_school_urns
    end
  end

  describe '#update' do
    before { subject.update(managed_organisations: new_organisations, managed_school_urns: new_school_urns) }

    context 'when new_managed_organisations is not all' do
      let(:new_organisations) { nil }
      let(:new_school_urns) { ['4321', '8765'] }

      it 'updates user_preference managed_organisations' do
        expect(user_preference.reload.managed_organisations).to eq new_organisations
      end

      it 'updates user_preference managed_school_urns' do
        expect(user_preference.reload.managed_school_urns).to eq new_school_urns
      end
    end

    context 'when new_managed_organisations is all' do
      let(:new_organisations) { ['all'] }
      let(:new_school_urns) { ['4321', '8765'] }

      it 'updates user_preference managed_organisations to all' do
        expect(user_preference.reload.managed_organisations).to eq 'all'
      end

      it 'updates user_preference managed_school_urns to empty array' do
        expect(user_preference.reload.managed_school_urns).to eq []
      end
    end
  end
end
