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
        expect(vacancy.errors[:starts_on])
        .to include(I18n.t('activerecord.errors.models.vacancy.attributes.starts_on.invalid_year'))
      end
    end

    context 'a record with a malformed ends_on year' do
      let(:vacancy) { FactoryBot.build(:vacancy, ends_on: Date.parse('12-01-202018')) }

      it 'shows an invalid year error' do
        vacancy.valid?
        expect(vacancy.errors[:ends_on])
        .to include(I18n.t('activerecord.errors.models.vacancy.attributes.ends_on.invalid_year'))
      end
    end

    context 'a record with a malformed publish_on year' do
      let(:vacancy) { FactoryBot.build(:vacancy, publish_on: Date.parse('12-01-202018')) }

      it 'shows an invalid year error' do
        vacancy.valid?
        expect(vacancy.errors[:publish_on])
        .to include(I18n.t('activerecord.errors.models.vacancy.attributes.publish_on.invalid_year'))
      end
    end

    context 'a record with a malformed expires_on year' do
      let(:vacancy) { FactoryBot.build(:vacancy, expires_on: Date.parse('12-01-202018')) }

      it 'shows an invalid year error' do
        vacancy.valid?
        expect(vacancy.errors[:expires_on])
        .to include(
          I18n.t('activerecord.errors.models.vacancy.attributes.expires_on.invalid_year'))
      end
    end
  end

  describe '#validate_date_fields(fields, record)' do
    context 'a record with blank fields' do
      let(:vacancies_with_missing_field) do
        [
          FactoryBot.build(:vacancy, publish_on_dd: ''),
          FactoryBot.build(:vacancy, publish_on_mm: ''),
          FactoryBot.build(:vacancy, publish_on_yyyy: ''),
        ]
      end
      let(:vacancy) { vacancies_with_missing_field.sample }

      it 'does not evaluate format when there are blank fields' do
        vacancy.valid?
        expect(vacancy.errors[:publish_on])
        .not_to include('Enter the date the role will be listed in the correct format')
      end
    end

    context 'a record with incorrect day' do
      let(:vacancy) { FactoryBot.build(:vacancy, expires_on_dd: '66') }

      it 'shows an invalid date error' do
        vacancy.valid?
        expect(vacancy.errors[:expires_on])
          .to include(I18n.t('activerecord.errors.models.vacancy.attributes.expires_on.invalid'))
      end
    end

    context 'a record with incorrect month' do
      let(:vacancy) { FactoryBot.build(:vacancy, expires_on_mm: '66') }

      it 'shows an invalid date error' do
        vacancy.valid?

        expect(vacancy.errors[:expires_on])
          .to include(I18n.t('activerecord.errors.models.vacancy.attributes.expires_on.invalid'))
      end
    end

    context 'a record with an impossible date' do
      let(:vacancy) { FactoryBot.build(:vacancy, publish_on_dd: '31', publish_on_mm: '02', publish_on_yyyy: '2020') }

      it 'shows an invalid date error' do
        vacancy.valid?

        expect(vacancy.errors[:publish_on])
          .to include(I18n.t('activerecord.errors.models.vacancy.attributes.publish_on.invalid'))
      end
    end
  end
end
