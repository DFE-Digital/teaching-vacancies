require 'rails_helper'

RSpec.describe VacanciesOptionsHelper, type: :helper do
  describe '#job_location_options' do
    before do
      allow(MultiSchoolJobsFeature).to receive(:enabled?).and_return(:multi_school_jobs_enabled?)
    end
    context 'when MultiSchoolJobsFeature is enabled' do
      let(:multi_school_jobs_enabled?) { true }

      it 'returns an array including the multi-school option' do
        expect(helper.job_location_options).to eq(
          [
            ['At one school in the trust', :at_one_school],
            ['At more than one school in the trust', :at_multiple_schools],
            ['At the trust\'s head office', :central_office],
          ],
        )
      end
    end

    context 'when MultiSchoolJobsFeature is not enabled' do
      let(:multi_school_jobs_enabled?) { false }

      it 'returns an array without the multi-school option' do
        allow(MultiSchoolJobsFeature).to receive(:enabled?).and_return(false)

        expect(helper.job_location_options).to eq(
          [
            ['At one school in the trust', :at_one_school],
            ['At the trust\'s head office', :central_office],
          ],
        )
      end
    end
  end

  describe '#job_role_options' do
    it 'returns an array of vacancy job role options' do
      expect(helper.job_role_options).to eq(
        [
          %w[Teacher teacher],
          %w[Leadership leadership],
          ['SEN specialist', 'sen_specialist'],
        ],
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
          [I18n.t('jobs.sort_by.expiry_time.ascending'), 'expiry_time_asc'],
        ],
      )
    end
  end

  describe '#working_pattern_options' do
    it 'returns an array of vacancy working patterns' do
      expect(helper.working_pattern_options).to eq(
        [
          %w[Full-time full_time],
          %w[Part-time part_time],
          ['Job share', 'job_share'],
        ],
      )
    end
  end
end
