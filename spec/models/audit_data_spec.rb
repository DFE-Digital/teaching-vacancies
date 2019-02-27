require 'rails_helper'

RSpec.describe AuditData, type: :model do
  let(:category) { 'vacancies' }
  let(:data) { { 'some' => 'data' } }

  let(:audit_datum) { create(:audit_data, category: category, data: data) }

  it 'creates some data' do
    expect(audit_datum.category).to eq(category)
    expect(audit_datum.data).to eq(data)
  end
end
