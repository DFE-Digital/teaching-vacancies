require 'rails_helper'

RSpec.describe HiringStaff::VacancyFilter do
  let(:user) { create :user }
  let(:organisation) { create :trust }
  let(:managed_organisations) { 'school_group' }
  let(:managed_school_ids) { %w[1234 5678] }
  let!(:user_preference) do
    create :user_preference, user: user, school_group: organisation,
                             managed_organisations: managed_organisations, managed_school_ids: managed_school_ids
  end

  subject { described_class.new(user, organisation) }

  describe '.initialize' do
    it 'sets the managed_organisations from user_preference' do
      expect(subject.managed_organisations).to eq managed_organisations
    end

    it 'sets the managed_school_ids from user_preference' do
      expect(subject.managed_school_ids).to eq managed_school_ids
    end
  end

  describe '#update' do
    before { subject.update(managed_organisations: new_organisations, managed_school_ids: new_school_ids) }

    context 'when new_managed_organisations is not all' do
      let(:new_organisations) { nil }
      let(:new_school_ids) { %w[4321 8765] }

      it 'updates user_preference managed_organisations' do
        expect(user_preference.reload.managed_organisations).to eq new_organisations
      end

      it 'updates user_preference managed_school_ids' do
        expect(user_preference.reload.managed_school_ids).to eq new_school_ids
      end
    end

    context 'when new_managed_organisations is all' do
      let(:new_organisations) { %w[all] }
      let(:new_school_ids) { %w[4321 8765] }

      it 'updates user_preference managed_organisations to all' do
        expect(user_preference.reload.managed_organisations).to eq 'all'
      end

      it 'updates user_preference managed_school_ids to empty array' do
        expect(user_preference.reload.managed_school_ids).to eq []
      end
    end
  end
end
