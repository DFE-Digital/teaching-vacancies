require 'rails_helper'

RSpec.describe JobLocationForm, type: :model do
  context 'validations' do
    describe '#job_location' do
      let(:job_location_form) { JobLocationForm.new(job_location: job_location) }

      context 'when job location is blank' do
        let(:job_location) { nil }

        it 'requests an entry in the field' do
          expect(job_location_form.valid?).to be false
          expect(job_location_form.errors.messages[:job_location][0])
            .to match(/Select the location/)
        end
      end

      context 'when job location has an unexpected value' do
        let(:job_location) { 'at_the_supermarket' }

        it 'requests an entry in the field' do
          expect(job_location_form.valid?).to be false
          expect(job_location_form.errors.messages[:job_location][0])
            .to match(/Select the location/)
        end
      end
    end
  end

  context 'when all attributes are valid' do
    job_location_form = JobLocationForm.new(state: 'create', job_location: 'central_office')

    it 'a JobLocationForm can be converted to a vacancy' do
      expect(job_location_form.valid?).to be true
      expect(job_location_form.vacancy.job_location).to eq('central_office')
    end
  end
end
