require 'rails_helper'

RSpec.describe UserPreferenceForm, type: :model do
  let(:current_user) { create(:user) }
  let(:current_organisation) { create(:school_group) }

  let(:managed_organisations) { ['school_group'] }
  let(:managed_school_urns) { ['12345', '23456'] }

  let(:params) { { managed_organisations: managed_organisations, managed_school_urns: managed_school_urns } }
  let(:subject) { described_class.new(current_user, current_organisation, params) }

  describe '#initialize' do
    context 'when a UserPreference does not exist' do
      it 'assigns attributes' do
        expect(subject.managed_organisations).to eql(managed_organisations)
        expect(subject.managed_school_urns).to eql(managed_school_urns)
      end
    end

    context 'when a UserPreference exists' do
      let(:params) { {} }

      before do
        UserPreference.find_or_create_by(
          user_id: current_user.id, school_group_id: current_organisation.id,
          managed_organisations: 'school_group', managed_school_urns: managed_school_urns
        )
      end

      it 'assigns attributes' do
        expect(subject.managed_organisations).to eql('school_group')
        expect(subject.managed_school_urns).to eql(managed_school_urns)
      end
    end
  end

  describe '#save' do
    context 'when managed_organisations includes all' do
      let(:managed_organisations) { ['all', 'school_group'] }

      it 'sets managed_organisations to all' do
        subject.save
        expect(subject.managed_organisations).to eql('all')
        expect(subject.managed_school_urns).to eql([])
      end
    end

    context 'when managed_organisations includes school_group' do
      it 'sets managed_organisations to school_group' do
        subject.save
        expect(subject.managed_organisations).to eql('school_group')
        expect(subject.managed_school_urns).to eql(managed_school_urns)
      end
    end
  end

  describe '#validations' do
    context 'when managed_organisations and managed_school_urns are blank' do
      let(:managed_organisations) { [] }
      let(:managed_school_urns) { [] }

      it 'validates presence of managed_organisations or managed_school_urns' do
        expect(subject.valid?).to be(false)
        expect(subject.errors.messages[:managed_organisations]).to include(
          I18n.t('hiring_staff_user_preference_errors.managed_organisations.blank')
        )
      end
    end
  end
end
