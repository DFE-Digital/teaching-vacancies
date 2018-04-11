require 'rails_helper'
RSpec.describe 'Auditor::Audit' do
  let(:vacancy) { build(:vacancy, :draft) }

  describe '#log' do
    it 'audits setting values to a model' do
      vacancy.job_description = 'A new description'
      audit = Auditor::Audit.new(vacancy, 'vacancy.test_create', 'test_session_id')
      audit.log { vacancy.save }

      audit_log = vacancy.activities.last
      expect(audit_log.key).to eq('vacancy.test_create')
      expect(audit_log.session_id).to eq('test_session_id')
      expect(audit_log.parameters.symbolize_keys)
        .to include(job_title: [nil, vacancy.job_title],
                    minimum_salary: [nil, vacancy.minimum_salary])
    end

    it 'audits any changes to a model' do
      vacancy.save
      job_description = vacancy.job_description
      vacancy.job_description = 'A new description'
      audit = Auditor::Audit.new(vacancy, 'vacancy.test', 'test_session_id')
      audit.log { vacancy.save }

      audit_log = vacancy.activities.last
      expect(audit_log.key).to eq('vacancy.test')
      expect(audit_log.session_id).to eq('test_session_id')
      expect(audit_log.parameters.symbolize_keys)
        .to eq(job_description: [job_description, 'A new description'])
    end
  end
end
