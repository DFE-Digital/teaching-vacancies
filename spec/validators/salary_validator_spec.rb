require 'rails_helper'

RSpec.describe SalaryValidator do
  describe '#validates_each(record, attribute, value)' do
    context 'mandatory checks' do
      let(:model) do
        TestModel.new
      end

      it 'does not allow the pound sign' do
        model.amount = '£123.33'

        expect(model).to_not be_valid
        expect(model.errors.messages[:amount])
          .to eq([I18n.t('errors.messages.salary.invalid_format', salary: 'Amount')])
      end

      it 'does not allow commas' do
        model.amount = '300,02'

        expect(model).to_not be_valid
        expect(model.errors.messages[:amount])
          .to eq([I18n.t('errors.messages.salary.invalid_format', salary: 'Amount')])
      end

      it 'does not allow fullstops if the decimal separation point is wrong' do
        model.amount = '300.330'

        expect(model).to_not be_valid
        expect(model.errors.messages[:amount])
          .to eq([I18n.t('errors.messages.salary.invalid_format', salary: 'Amount')])
      end

      it 'does not allow any non numeric characters' do
        model.amount = 'A300330'

        expect(model).to_not be_valid
        expect(model.errors.messages[:amount])
          .to eq([I18n.t('errors.messages.salary.invalid_format', salary: 'Amount')])
      end

      it 'allows fullstops if the decimal separation point is correct' do
        model.amount = '30000.50'

        expect(model).to be_valid
      end

      it 'accepts integer numbers' do
        model.amount = '34000'

        expect(model).to be_valid
      end

      it 'validates the maximum allowed value' do
        model.amount = '200000000000000'

        expect(model).to_not be_valid
        expect(model.errors.messages[:amount]).to eq(['Amount must be less than £200,000'])
      end
    end

    context 'optional checks' do
      let(:model) do
        TestModelOnlyMandatory.new
      end

      context 'if minimum_value: true' do
        it 'validates that the value is not less than the minimum allowed' do
          stub_const("#{SalaryValidator}::MIN_SALARY_ALLOWED", '400')
          model.amount = '12.23'

          expect(model).to_not be_valid
          expect(model.errors[:amount]).to eq([I18n.t('errors.messages.salary.lower_than_minimum_payscale',
                                                      minimum_salary: '£400')])
        end
      end
    end
  end
end

class TestModel
  include ActiveModel::Validations

  attr_accessor :amount
  validates :amount, salary: { presence: true }
end

class TestModelOnlyMandatory
  include ActiveModel::Validations

  attr_accessor :amount
  validates :amount, salary: { presence: true, minimum_value: true }
end
