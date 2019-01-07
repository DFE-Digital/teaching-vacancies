require 'rails_helper'

RSpec.describe DateFormatValidator do
  describe '#validate(record)' do
    context 'a complete and correct record' do
      let(:vacancy) { FactoryBot.build(:vacancy, :complete) }

      it 'passes validations' do
        expect(vacancy.valid?).to be_truthy
      end
    end

    context 'a record with a malformed starts_on year' do
      let(:vacancy) { FactoryBot.build(:vacancy, starts_on: Date.parse('12-01-202018')) }

      it 'shows an invalid year error' do
        vacancy.valid?
        expect(vacancy.errors[:starts_on]).to include(I18n.t('errors.messages.year_invalid'))
      end
    end

    context 'a record with a malformed ends_on year' do
      let(:vacancy) { FactoryBot.build(:vacancy, ends_on: Date.parse('12-01-202018')) }

      it 'shows an invalid year error' do
        vacancy.valid?
        expect(vacancy.errors[:ends_on]).to include(I18n.t('errors.messages.year_invalid'))
      end
    end

    context 'a record with a malformed publish_on year' do
      let(:vacancy) { FactoryBot.build(:vacancy, publish_on: Date.parse('12-01-202018')) }

      it 'shows an invalid year error' do
        vacancy.valid?
        expect(vacancy.errors[:publish_on]).to include(I18n.t('errors.messages.year_invalid'))
      end
    end

    context 'a record with a malformed expires_on year' do
      let(:vacancy) { FactoryBot.build(:vacancy, expires_on: Date.parse('12-01-202018')) }

      it 'shows an invalid year error' do
        vacancy.valid?
        expect(vacancy.errors[:expires_on]).to include(I18n.t('errors.messages.year_invalid'))
      end
    end
  end
end
