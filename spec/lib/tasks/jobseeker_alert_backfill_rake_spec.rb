require 'rails_helper'

RSpec.describe 'rake jobseeker_alerts:statistics:backfill:alert_data', type: :task do
  context 'when audit data does not exist for a subscription' do
    let!(:subscription1) { create(:subscription, search_criteria: { keyword: 'english' }.to_json) }
    let!(:subscription2) { create(:subscription, search_criteria: { keyword: 'science' }.to_json) }
    let!(:subscription3) { create(:subscription, search_criteria: { keyword: 'french' }.to_json) }
    let!(:subscription4) { create(:subscription, search_criteria: { keyword: 'maths' }.to_json) }

    it 'creates audit data' do
      expect { task.invoke }.to change { AuditData.count }.by(4)
    end
  end
end