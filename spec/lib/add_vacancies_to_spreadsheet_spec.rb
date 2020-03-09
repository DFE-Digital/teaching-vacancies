require 'rails_helper'
require 'add_vacancies_to_spreadsheet'

RSpec.describe AddVacanciesToSpreadsheet do
  let(:category) { 'vacancies' }
  let(:spreadsheet_id) { 'VACANCY_FEEDBACK_SPREADSHEET_ID' }

  let!(:existing_data) { Timecop.freeze(2.days.ago) { create_list(:vacancy, 3) } }
  let!(:new_data) { create_list(:vacancy, 3) }
  let(:expected_new_spreadsheet_rows) do
    new_data.map do |vacancy|
      [
        Time.zone.now.to_s,
        vacancy.id,
        vacancy.slug,
        vacancy.created_at.to_s,
        vacancy.status,
        vacancy.publish_on,
        vacancy.expires_on,
        vacancy.starts_on,
        vacancy.ends_on,
        vacancy.working_patterns.join(','),
        vacancy.school.urn,
        vacancy.school.county
      ]
    end
  end

  subject { described_class.new }

  it_behaves_like 'ExportToSpreadsheet'
end
