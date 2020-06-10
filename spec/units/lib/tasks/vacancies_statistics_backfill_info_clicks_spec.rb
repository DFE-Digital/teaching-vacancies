require 'rails_helper'

RSpec.describe 'rake vacancies:statistics:backfill:info_clicks', type: :task do
  it 'Backfills the total more info clicks' do
    vacancy1 = create(:vacancy, :published)
    vacancy2 = create(:vacancy, :published)
    vacancy3 = create(:vacancy, :published)

    2.times { Auditor::Audit.new(vacancy1, 'vacancy.get_more_information', 'sample').log }
    3.times { Auditor::Audit.new(vacancy2, 'vacancy.get_more_information', 'sample').log }
    4.times { Auditor::Audit.new(vacancy3, 'vacancy.get_more_information', 'sample').log }

    task.invoke

    expect(vacancy1.reload.total_get_more_info_clicks).to eq(2)
    expect(vacancy2.reload.total_get_more_info_clicks).to eq(3)
    expect(vacancy3.reload.total_get_more_info_clicks).to eq(4)
  end
end
