require 'rails_helper'
require 'add_general_feedback_to_spreadsheet'

RSpec.describe AddGeneralFeedbackToSpreadsheet do
  let(:category) { 'general_feedback' }
  let(:spreadsheet_id) { 'GENERAL_FEEDBACK_SPREADSHEET_ID' }

  let!(:existing_data) { Timecop.freeze(2.days.ago) { create_list(:general_feedback, 3) } }
  let!(:new_data) { create_list(:general_feedback, 3) }

  subject { described_class.new }

  it_behaves_like 'ExportToSpreadsheet'
end