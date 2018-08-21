require 'rails_helper'

RSpec.describe SalaryValidator do
  describe '#validates_each(record, attribute, value)' do
    context 'mandatory checks' do
      let(:model) { TestModel.new }

      it 'does not allow the pound sign' do
        model.amount = '£123.33'

        expect(model).to_not be_valid
        expect(model.errors.messages[:amount]).to eq([I18n.t('errors.messages.salary.invalid_format')])
      end

      it 'does not allow commas' do
        model.amount = '300,02'

        expect(model).to_not be_valid
        expect(model.errors.messages[:amount]).to eq([I18n.t('errors.messages.salary.invalid_format')])
      end

      it 'does not allow fullstops if the decimal separation point is wrong' do
        model.amount = '300.330'

        expect(model).to_not be_valid
        expect(model.errors.messages[:amount]).to eq([I18n.t('errors.messages.salary.invalid_format')])
      end

      it 'does not allow any non numeric characters' do
        model.amount = 'A300330'

        expect(model).to_not be_valid
        expect(model.errors.messages[:amount]).to eq([I18n.t('errors.messages.salary.invalid_format')])
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
        expect(model.errors.messages[:amount]).to eq(['must not be more than £200000'])
      end
    end

    context 'optional checks' do
      let(:school) { create(:school) }
      let(:model) { TestModelOnlyMandatory.new(school) }

      before(:each) do
        minimum = create(:pay_scale, salary: 23450)
        other = create(:pay_scale, salary: 40050)
        regional_pay_band_area = school.regional_pay_band_area
        regional_pay_band_area.pay_scales << minimum << other
      end

      context 'if minimum_value: true' do
        it 'validates that the value is not less than the minimum allowed' do
          model.amount = '12.23'

          expect(model).to_not be_valid
          expect(model.errors[:amount]).to eq([I18n.t('errors.messages.salary.lower_than_minimum_payscale',
                                                      minimum_salary: '£23450')])
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

  def initialize(school)
    @school = school
  end

  def school_minimum_salary
    @school.minimum_pay_scale_salary
  end
end
