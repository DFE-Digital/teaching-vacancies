require 'rails_helper'

RSpec.describe DateFormatValidator do
  describe '#validate(record)' do
    context 'a complete and correct record' do
      let(:vacancy) { FactoryBot.build(:vacancy, :complete) }

      it 'passes validations' do
        expect(vacancy.valid?).to be_truthy
      end
    end

    context 'a record with a malformed year' do
      let(:records) do
        {
          starts_on: FactoryBot.build(:vacancy, starts_on: Date.parse('12-01-111')),
          ends_on: FactoryBot.build(:vacancy, ends_on: Date.parse('12-01-12345')),
          publish_on: FactoryBot.build(:vacancy, publish_on: Date.parse('12-01-202089')),
          expires_on: FactoryBot.build(:vacancy, expires_on: Date.parse('12-01-20298982323'))
        }
      end

      it 'shows an invalid date format error' do
        tested_field = [:starts_on, :ends_on, :publish_on, :expires_on].sample
        vacancy = records[tested_field]
        vacancy.valid?
        expect(vacancy.errors[tested_field])
        .to include(I18n.t("activerecord.errors.models.vacancy.attributes.#{tested_field}.invalid"))
      end
    end
  end

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
      .not_to include('Use the correct format for the date the role will be listed')
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
