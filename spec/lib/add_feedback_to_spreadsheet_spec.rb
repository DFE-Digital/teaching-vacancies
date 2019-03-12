require 'rails_helper'
require 'add_feedback_to_spreadsheet'

RSpec.describe AddFeedbackToSpreadsheet do
  let(:category) { 'feedback' }
  let(:spreadsheet_id) { 'FEEDBACK_SPREADSHEET_ID' }

  let!(:existing_data) { Timecop.freeze(2.days.ago) { create_list(:feedback, 3) } }
  let!(:new_data) { create_list(:feedback, 3) }

  subject { described_class.new }

  it_behaves_like 'ExportToSpreadsheet'
end