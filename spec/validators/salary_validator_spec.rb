require 'rails_helper'

RSpec.describe SalaryValidator do
  describe '#validates_each(record, attribute, value)' do
    let(:model)  do
      class TestModel
        include ActiveModel::Validations

        attr_accessor :amount
        validates :amount, salary: { presence: true, minimum_value: true }
      end
      TestModel.new
    end

    it 'validates the salary format' do
      model.amount = '$12.23'
      model.valid?

      expect(model.errors[:amount].first).to eq(I18n.t('errors.messages.salary.invalid_format'))
    end

    it 'validates the salary format' do
      model.amount = '$12.23'
      model.valid?

      expect(model.errors[:amount].first).to eq(I18n.t('errors.messages.salary.invalid_format'))
    end

    context 'optional checks' do
      context 'if presence: true' do
        it 'validates that the value is not blank' do
          model.amount = nil
          model.valid?

          expect(model.errors[:amount].first).to eq(I18n.t('errors.messages.blank'))
        end
      end

      context 'if minimum_value: true' do
        it 'validates that the value is not less than the minimum allowed' do
          stub_const('SalaryValidator::MIN_SALARY_ALLOWED', '400')

          model.amount = '12.23'
          model.valid?

          expect(model.errors[:amount].first).to eq(I18n.t('errors.messages.salary.lower_than_minimum_payscale',
                                                           minimum_salary: '£400'))
        end
      end
    end
  end
end
