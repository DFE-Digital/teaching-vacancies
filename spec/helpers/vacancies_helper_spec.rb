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
          [I18n.t('jobs.sort_by.expiry_time.descending'), 'expiry_time_desc'],
          [I18n.t('jobs.sort_by.expiry_time.ascending'), 'expiry_time_asc']
        ]
      )
    end
  end

  describe '#new_sections' do
    let(:vacancy) { double('vacancy').as_null_object }

    it 'includes supporting_documents for legacy listings' do
      allow(vacancy).to receive(:supporting_documents).and_return(nil)
      expect(helper.new_sections(vacancy)).to include('supporting_documents')
    end

    it 'includes job_details for legacy listings with job_roles as nil' do
      allow(vacancy).to receive_message_chain(:job_roles, :any?).and_return(false)
      expect(helper.new_sections(vacancy)).to include('job_details')
    end

    it 'includes job_details for legacy listings with missing subjects' do
      allow(helper).to receive(:missing_subjects?).with(vacancy).and_return(true)
      expect(helper.new_sections(vacancy)).to include('job_details')
    end
  end

  describe '#review_heading' do
    let(:vacancy) { double('vacancy').as_null_object }
    let(:school) { build(:school) }

    it 'returns edit heading if vacancy is published' do
      allow(vacancy).to receive(:published?).and_return(true)

      expect(review_heading(vacancy, school)).to eql(I18n.t('jobs.edit_heading', school: school.name))
    end

    it 'returns copy review heading if vacancy state is copy' do
      allow(vacancy).to receive(:published?).and_return(false)
      allow(vacancy).to receive(:state).and_return('copy')

      expect(review_heading(vacancy, school)).to eql(I18n.t('jobs.copy_review_heading'))
    end

    it 'returns review heading' do
      allow(vacancy).to receive(:published?).and_return(false)
      allow(vacancy).to receive(:state).and_return('not_copy_review')

      expect(review_heading(vacancy, school)).to eql(I18n.t('jobs.review_heading'))
    end
  end

  describe '#page_title' do
    let(:vacancy) { double('vacancy').as_null_object }
    let(:school) { build(:school) }

    it 'returns edit title if vacancy is published' do
      allow(vacancy).to receive(:published?).and_return(true)

      expect(page_title(vacancy, school)).to eql(I18n.t('jobs.edit_heading', school: school.name))
    end

    it 'returns copy title if vacancy state is copy' do
      allow(vacancy).to receive(:published?).and_return(false)
      allow(vacancy).to receive(:state).and_return('copy')
      allow(vacancy).to receive(:job_title).and_return('Test job title')

      expect(page_title(vacancy, school)).to eql(I18n.t('jobs.copy_page_title', job_title: 'test job title'))
    end

    it 'returns create a job title' do
      allow(vacancy).to receive(:published?).and_return(false)
      allow(vacancy).to receive(:state).and_return('not_copy_review')

      expect(page_title(vacancy, school)).to eql(I18n.t('jobs.create_a_job', school: school.name))
    end
  end
end
