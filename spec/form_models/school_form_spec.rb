require 'rails_helper'

RSpec.describe SchoolForm, type: :model do
  let(:school) { create(:school) }
  let(:school_form) { described_class.new(school_id: school_id) }

  describe 'validations' do
    describe '#school_id' do
      context 'when school id is blank' do
        let(:school_id) { nil }

        it 'requests an entry in the field' do
          expect(school_form.valid?).to be false
          expect(school_form.errors.messages[:school_id]).to include(
            I18n.t('activemodel.errors.models.school_form.attributes.school_id.blank')
          )
        end
      end
    end
  end

  context 'when all attributes are valid' do
    let(:school_id) { school.id }

    it 'a SchoolForm can be converted to a vacancy' do
      expect(school_form.valid?).to be true
      expect(school_form.vacancy.school_id).to eql(school.id)
    end
  end
end
