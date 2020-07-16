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

    describe '#about_organisation' do
      job_summary_form = JobSummaryForm.new(about_organisation: nil)

      context 'when about school is blank' do
        let(:about_organisation) { nil }

        it 'requests an entry in the field' do
          expect(job_summary_form.valid?).to be false
          expect(job_summary_form.errors.messages[:about_organisation])
            .to include(
              I18n.t('activemodel.errors.models.job_summary_form.attributes.about_organisation.blank')
            )
        end
      end
    end
  end

  context 'when all attributes are valid' do
    job_summary_form = JobSummaryForm.new(state: 'create', job_summary: 'Summary about the job',
                                          about_organisation: 'Description of the school')

    it 'a JobSummaryForm can be converted to a vacancy' do
      expect(job_summary_form.valid?).to be true
      expect(job_summary_form.vacancy.job_summary).to eq('Summary about the job')
      expect(job_summary_form.vacancy.about_organisation).to eq('Description of the school')
    end
  end
end
