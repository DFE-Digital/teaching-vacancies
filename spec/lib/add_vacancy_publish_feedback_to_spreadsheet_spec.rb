require 'rails_helper'
require 'add_vacancy_publish_feedback_to_spreadsheet'

RSpec.describe AddVacancyPublishFeedbackToSpreadsheet do
  let(:category) { 'vacancy_publish_feedback' }
  let(:spreadsheet_id) { 'VACANCY_PUBLISH_FEEDBACK_SPREADSHEET_ID' }

  let!(:existing_data) { Timecop.freeze(2.days.ago) { create_list(:vacancy_publish_feedback, 3) } }
  let!(:new_data) { create_list(:vacancy_publish_feedback, 3) }

  subject { described_class.new }

  it_behaves_like 'ExportToSpreadsheet'

  context 'with no user attached to the feedback' do
    let!(:new_data) { create_list(:vacancy_publish_feedback, 3, :old_with_no_user) }
    it_behaves_like 'ExportToSpreadsheet'
  end
end