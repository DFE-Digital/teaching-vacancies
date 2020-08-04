require 'rails_helper'

RSpec.describe ManagedOrganisationsForm, type: :model do
  let(:managed_organisations) { ['school_group'] }
  let(:managed_school_ids) { ['12345', '23456'] }

  let(:params) { { managed_organisations: managed_organisations, managed_school_ids: managed_school_ids } }
  let(:subject) { described_class.new(params) }

  describe '#initialize' do
    it 'assigns attributes' do
      expect(subject.managed_organisations).to eql(managed_organisations)
      expect(subject.managed_school_ids).to eql(managed_school_ids)
    end
  end

  describe '#validations' do
    context 'when managed_organisations and managed_school_ids are blank' do
      let(:managed_organisations) { '' }
      let(:managed_school_ids) { [] }

      it 'validates presence of managed_organisations or managed_school_ids' do
        expect(subject.valid?).to be(false)
        expect(subject.errors.messages[:managed_organisations]).to include(
          I18n.t('hiring_staff_user_preference_errors.managed_organisations.blank')
        )
      end
    end
  end
end
