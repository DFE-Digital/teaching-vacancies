require 'rails_helper'

RSpec.describe JobSummaryForm, type: :model do
  context 'validations' do
    describe '#job_summary' do
      job_summary_form = JobSummaryForm.new(job_summary: nil)

      context 'when job summary is blank' do
        let(:job_summary) { nil }

        it 'requests an entry in the field' do
          expect(job_summary_form.valid?).to be false
          expect(job_summary_form.errors.messages[:job_summary])
            .to include(
              I18n.t('activemodel.errors.models.job_summary_form.attributes.job_summary.blank')
            )
        end
      end
    end

    describe '#about_school' do
      let(:job_summary_form) { JobSummaryForm.new(about_school: nil, job_location: job_location) }

      context 'when about school is blank' do
        context 'for a vacancy at a single school in a trust' do
          let(:job_location) { 'at_one_school' }

          it 'requests the user to complete the about school field' do
            expect(job_summary_form.valid?).to be false
            expect(job_summary_form.errors.messages[:about_school].first).to match(/school/)
          end
        end

        context 'for a vacancy at a single school NOT in a trust' do
          let(:job_location) { nil }

          it 'requests the user to complete the about school field' do
            expect(job_summary_form.valid?).to be false
            expect(job_summary_form.errors.messages[:about_school].first).to match(/school/)
          end
        end

        context 'for a vacancy at a school group' do
          let(:job_location) { 'central_office' }

          it 'requests the user to complete the about trust field' do
            expect(job_summary_form.valid?).to be false
            expect(job_summary_form.errors.messages[:about_school].first).to match(/trust/)
          end
        end
      end
    end
  end

  context 'when all attributes are valid' do
    job_summary_form = JobSummaryForm.new(state: 'create', job_summary: 'Summary about the job',
                                          about_school: 'Description of the school')

    it 'a JobSummaryForm can be converted to a vacancy' do
      expect(job_summary_form.valid?).to be true
      expect(job_summary_form.vacancy.job_summary).to eq('Summary about the job')
      expect(job_summary_form.vacancy.about_school).to eq('Description of the school')
    end
  end
end
