require 'rails_helper'
RSpec.describe PayScale, type: :model do
  context 'scopes' do
    describe '#default' do
      it 'orders by index' do
        create(:pay_scale, index: 23)
        last = create(:pay_scale, index: 30)
        first = create(:pay_scale, index: 1)
        create(:pay_scale, index: 27)

        expect(PayScale.all.first).to eq(first)
        expect(PayScale.all.last).to eq(last)
      end
    end
  end
end
