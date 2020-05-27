require 'rails_helper'

RSpec.describe JobSpecificationForm, type: :model do
  subject { JobSpecificationForm.new({}) }

  context 'validations' do
    describe '#working_patterns' do
      let(:job_specification) { JobSpecificationForm.new(working_patterns: nil) }

      it 'requests an entry in the field' do
        expect(job_specification.valid?).to be false
        expect(job_specification.errors.messages[:working_patterns][0])
          .to eq('Select a working pattern')
      end
    end

    describe '#job_title' do
      let(:job_specification) { JobSpecificationForm.new(job_title: job_title) }

      context 'when title is blank' do
        let(:job_title) { nil }

        it 'requests an entry in the field' do
          expect(job_specification.valid?).to be false
          expect(job_specification.errors.messages[:job_title][0])
            .to eq('Enter a job title')
        end
      end

      context 'when title is too short' do
        let(:job_title) { 'aa' }

        it 'validates minimum length' do
          expect(job_specification.valid?).to be false
          expect(job_specification.errors.messages[:job_title][0])
            .to eq(I18n.t('activemodel.errors.models.job_specification_form.attributes.job_title.too_short', count: 4))
        end
      end

      context 'when title is too long' do
        let(:job_title) { 'Long title' * 100 }

        it 'validates max length' do
          expect(job_specification.valid?).to be false
          expect(job_specification.errors.messages[:job_title][0])
            .to eq(I18n.t('activemodel.errors.models.job_specification_form.attributes.job_title.too_long', count: 100))
        end
      end

      context 'when title contains HTML tags' do
        let(:job_title) { 'Title with <p>tags</p>' }

        it 'validates presence of HTML tags' do
          expect(job_specification.valid?).to be false
          expect(job_specification.errors.messages[:job_title]).to include(
            I18n.t('activemodel.errors.models.job_specification_form.attributes.job_title.invalid_characters')
          )
        end
      end

      context 'when title does not contain HTML tags' do
        context 'job title contains &' do
          let(:job_title) { 'Job & another job' }

          it 'does not validate presence of HTML tags' do
            expect(job_specification.errors.messages[:job_title]).to_not include(
              I18n.t('activemodel.errors.models.job_specification_form.attributes.job_title.invalid_characters')
            )
          end
        end
      end
    end
  end

  describe '#starts_on' do
    it 'has no validation applied when blank' do
      job_specification_form = JobSpecificationForm.new(starts_on: nil)
      job_specification_form.valid?

      expect(job_specification_form).to have(:no).errors_on(:starts_on)
    end

    it 'must be in the future' do
      job_specification_form = JobSpecificationForm.new(starts_on: 1.day.ago)
      expect(job_specification_form.valid?).to be false

      expect(job_specification_form).to have(1).errors_on(:starts_on)
      expect(job_specification_form.errors.messages[:starts_on][0])
        .to eq('Start date must be in the future')
    end

    it 'must be before the ends_on date' do
      job_specification_form = JobSpecificationForm.new(starts_on: Time.zone.today + 10.days,
                                                        ends_on: Time.zone.today + 5.days)
      expect(job_specification_form.valid?).to be false

      expect(job_specification_form).to have(1).errors_on(:starts_on)
      expect(job_specification_form.errors.messages[:starts_on][0])
        .to eq('Start date must be before end date')
    end

    it 'must be after the closing date' do
      job_specification_form = JobSpecificationForm.new(starts_on: Time.zone.today,
                                                        expires_on: Time.zone.tomorrow)
      expect(job_specification_form.valid?).to be false

      expect(job_specification_form).to have(1).errors_on(:starts_on)
      expect(job_specification_form.errors.messages[:starts_on][0])
        .to eq('Start date must be after application deadline')
    end
  end

  describe '#ends_on' do
    it 'has no validation applied when blank' do
      job_specification_form = JobSpecificationForm.new(ends_on: nil)
      job_specification_form.valid?

      expect(job_specification_form).to have(:no).errors_on(:ends_on)
    end

    it 'must be in the future' do
      job_specification_form = JobSpecificationForm.new(ends_on: 1.day.ago)
      expect(job_specification_form.valid?).to be false

      expect(job_specification_form).to have(1).errors_on(:ends_on)
      expect(job_specification_form.errors.messages[:ends_on][0])
        .to eq('End date must be in the future')
    end

    it 'must be after the closing date' do
      job_specification_form = JobSpecificationForm.new(ends_on: Time.zone.today,
                                                        expires_on: Time.zone.tomorrow)
      expect(job_specification_form.valid?).to be false

      expect(job_specification_form).to have(1).errors_on(:ends_on)
      expect(job_specification_form.errors.messages[:ends_on][0])
        .to eq('End date must be after application deadline')
    end
  end

  context 'when all attributes are valid' do
    it 'a JobSpecificationForm can be converted to a vacancy' do
      job_specification_form = JobSpecificationForm.new(state: 'create', job_title: 'English Teacher',
                                                        job_roles: [I18n.t('jobs.job_role_options.teacher')],
                                                        working_patterns: ['full_time'],
                                                        subjects: ['Maths'],
                                                        newly_qualified_teacher: true)

      expect(job_specification_form.valid?).to be true
      expect(job_specification_form.vacancy.job_title).to eq('English Teacher')
      expect(job_specification_form.vacancy.job_roles).to include(I18n.t('jobs.job_role_options.teacher'))
      expect(job_specification_form.vacancy.working_patterns).to eq(['full_time'])
      expect(job_specification_form.vacancy.subjects).to include('Maths')
      expect(job_specification_form.vacancy.newly_qualified_teacher).to eq(true)
    end
  end
end
