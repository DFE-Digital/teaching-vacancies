require 'rails_helper'
RSpec.describe JobSpecificationForm, type: :model do
  subject { JobSpecificationForm.new({}) }

  context 'validations' do
    it { should validate_presence_of(:job_title) }
    it { should validate_presence_of(:headline) }
    it { should validate_presence_of(:job_description) }
    it { should validate_presence_of(:minimum_salary) }
    it { should validate_presence_of(:working_pattern) }

    describe '#minimum_salary' do
      describe '#minimum_salary_lower_than_maximum' do
        let(:job_specification) do
          JobSpecificationForm.new(headline: 'headline', job_title: 'job title',
                                   job_description: 'description', working_pattern: :full_time,
                                   minimum_salary: 20, maximum_salary: 10)
        end

        it 'the minimum salary should be less than the maximum salary' do
          expect(job_specification.valid?).to be false
          expect(job_specification.errors.messages[:minimum_salary][0])
            .to eq('must be lower than the maximum salary')
        end
      end
    end
  end

  context 'when all attributes are valid' do
    let(:payscale) { create(:pay_scale) }
    let(:main_subject) { create(:subject) }
    let(:leadership) { create(:leadership) }

    it 'a JobSpecificationForm can be converted to a vacancy' do
      job_specification_form = JobSpecificationForm.new(headline: 'headline', job_title: 'job title',
                               job_description: 'description', working_pattern: :full_time,
                               minimum_salary: 20, maximum_salary: 40, benefits: 'benefits',
                               subject_id: main_subject.id, pay_scale_id: payscale.id,
                               leadership_id: leadership.id)

      expect(job_specification_form.valid?).to be true
      expect(job_specification_form.vacancy.job_title).to eq('job title')
      expect(job_specification_form.vacancy.job_description).to eq('description')
      expect(job_specification_form.vacancy.headline).to eq('headline')
      expect(job_specification_form.vacancy.working_pattern).to eq("full_time")
      expect(job_specification_form.vacancy.minimum_salary).to eq(20)
      expect(job_specification_form.vacancy.maximum_salary).to eq(40)
      expect(job_specification_form.vacancy.benefits).to eq('benefits')
      expect(job_specification_form.vacancy.pay_scale.label).to eq(payscale.label)
      expect(job_specification_form.vacancy.subject.name).to eq(main_subject.name)
      expect(job_specification_form.vacancy.leadership.title).to eq(leadership.title)
    end
  end
end
