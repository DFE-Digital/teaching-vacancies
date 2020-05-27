require 'rails_helper'

RSpec.describe VacanciesHelper, type: :helper do
  describe '#working_pattern_options' do
    it 'returns an array of vacancy working patterns' do
      expect(helper.working_pattern_options).to eq(
        [
          ['Full-time', 'full_time'],
          ['Part-time', 'part_time'],
          ['Job share', 'job_share'],
          ['Compressed hours', 'compressed_hours'],
          ['Staggered hours', 'staggered_hours']
        ]
      )
    end
  end

  describe '#job_sorting_options' do
    it 'returns an array of vacancy job sorting options' do
      expect(helper.job_sorting_options).to eq(
        [
          [I18n.t('jobs.sort_by.most_relevant'), ''],
          [I18n.t('jobs.sort_by.publish_on.descending'), 'publish_on_desc'],
          [I18n.t('jobs.sort_by.publish_on.ascending'), 'publish_on_asc'],
          [I18n.t('jobs.sort_by.expiry_time.descending'), 'expiry_time_desc'],
          [I18n.t('jobs.sort_by.expiry_time.ascending'), 'expiry_time_asc']
        ]
      )
    end
  end

  describe '#new_sections' do
    let(:vacancy) { double('vacancy').as_null_object }

    it 'should include supporting_documents for legacy listings' do
      allow(vacancy).to receive(:supporting_documents).and_return(nil)
      expect(helper.new_sections(vacancy)).to include('supporting_documents')
    end

    it 'should include job_details for legacy listings' do
      allow(vacancy).to receive_message_chain(:job_roles, :any?).and_return(false)
      expect(helper.new_sections(vacancy)).to include('job_details')
    end

    it 'should include job_details for legacy listings' do
      allow(helper).to receive(:missing_subjects?).with(vacancy).and_return(true)
      expect(helper.new_sections(vacancy)).to include('job_details')
    end
  end
end
