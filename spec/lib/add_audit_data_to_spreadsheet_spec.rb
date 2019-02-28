require 'rails_helper'
require 'add_audit_data_to_spreadsheet'

RSpec.describe AddAuditDataToSpreadsheet do
  let(:category) { 'vacancies' }
  let(:spreadsheet_id) { 'AUDIT_SPREADSHEET_ID' }

  let!(:existing_data) { Timecop.freeze(2.days.ago) { create_list(:audit_data, 3, category: 'vacancies') } }
  let!(:new_data) { create_list(:audit_data, 3, category: 'vacancies') }
  let!(:other_data) { create_list(:audit_data, 3, category: 'sign_in_events') }

  it_behaves_like 'ExportToSpreadsheet'
end