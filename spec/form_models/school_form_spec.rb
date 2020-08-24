require 'rails_helper'

RSpec.describe SchoolForm, type: :model do
  let(:school) { create(:school) }
  let(:school_form) { described_class.new(organisation_id: organisation_id) }

  describe 'validations' do
    describe '#organisation_id' do
      context 'when school id is blank' do
        let(:organisation_id) { nil }

        it 'requests an entry in the field' do
          expect(school_form.valid?).to be false
          expect(school_form.errors.messages[:organisation_id]).to include(
            I18n.t('activemodel.errors.models.school_form.attributes.organisation_id.blank')
          )
        end
      end
    end
  end

  context 'when all attributes are valid' do
    let(:organisation_id) { school.id }

    it 'a SchoolForm can be converted to a vacancy' do
      expect(school_form.valid?).to be true
      expect(school_form.organisation_id).to eql(school.id)
    end
  end
end
