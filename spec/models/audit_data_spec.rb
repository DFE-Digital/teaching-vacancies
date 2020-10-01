require 'rails_helper'

RSpec.describe AuditData, type: :model do
  let(:category) { 'vacancies' }
  let(:data) { { 'some' => 'data' } }

  let(:audit_data) { create(:audit_data, category: category, data: data) }

  it 'creates some data' do
    expect(audit_data.category).to eq(category)
    expect(audit_data.data).to eq(data)
  end

  describe '#to_row' do
    let(:row) { audit_data.to_row }

    it 'returns a row' do
      expect(row).to eq([Time.zone.now.to_s, 'data'])
    end
  end
end
