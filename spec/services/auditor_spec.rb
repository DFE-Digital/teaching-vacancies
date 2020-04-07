require 'rails_helper'
RSpec.describe 'Auditor::Audit' do
  let(:vacancy) { build(:vacancy, :draft) }

  describe '#log' do
    it 'audits setting values to a model' do
      vacancy.job_summary = 'A new description'
      audit = Auditor::Audit.new(vacancy, 'vacancy.test_create', 'test_session_id')
      audit.log { vacancy.save }

      audit_log = vacancy.activities.last
      expect(audit_log.key).to eq('vacancy.test_create')
      expect(audit_log.session_id).to eq('test_session_id')
      expect(audit_log.parameters.symbolize_keys)
        .to include(job_title: [nil, vacancy.job_title])
    end

    it 'audits any changes to a model' do
      vacancy.save
      job_summary = vacancy.job_summary
      vacancy.job_summary = 'A new description'
      audit = Auditor::Audit.new(vacancy, 'vacancy.test', 'test_session_id')
      audit.log { vacancy.save }

      audit_log = vacancy.activities.last
      expect(audit_log.key).to eq('vacancy.test')
      expect(audit_log.session_id).to eq('test_session_id')
      expect(audit_log.parameters.symbolize_keys)
        .to eq(job_summary: [job_summary, 'A new description'])
    end
  end

  describe '#log_without_association' do
    it 'audits without requiring an associated model' do
      audit = Auditor::Audit.new(nil, 'dfe-sign-in.test', 'test_session_id')
      audit.log_without_association

      audit_log = PublicActivity::Activity.last
      expect(audit_log.key).to eq('dfe-sign-in.test')
      expect(audit_log.session_id).to eq('test_session_id')
      expect(audit_log.trackable).to eq(nil)
    end
  end
end

RSpec.describe 'Auditor::Auth' do
  describe '#yestedays_activities' do
    it 'returns the auth related activities taken place yesterday' do
      Timecop.freeze(2.days.ago) do
        Auditor::Audit.new(nil, 'dfe-sign-in.test', 'test_session_id').log_without_association
      end

      Timecop.freeze(1.day.ago) do
        Auditor::Audit.new(nil, 'azure.authentication', 'test_session_id').log_without_association
        Auditor::Audit.new(nil, 'dfe-sign-in.authentication.failure', 'test_session_id').log_without_association
      end

      Auditor::Audit.new(nil, 'dfe-sign-in.authentication.success', 'test_session_id').log_without_association

      latest_activities = Auditor::Auth.new.yesterdays_activities
      expect(latest_activities.count).to eq(2)
      expect(latest_activities.first.key).to eq('azure.authentication')
      expect(latest_activities.last.key).to eq('dfe-sign-in.authentication.failure')

      Timecop.return
    end
  end
end
