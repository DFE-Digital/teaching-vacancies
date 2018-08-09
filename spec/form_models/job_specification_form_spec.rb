require 'rails_helper'
RSpec.describe JobSpecificationForm, type: :model do
  subject { JobSpecificationForm.new({}) }

  context 'validations' do
    it { should validate_presence_of(:job_title) }
    it { should validate_presence_of(:job_description) }
    it { should validate_presence_of(:minimum_salary) }
    it { should validate_presence_of(:working_pattern) }

    describe '#minimum_salary' do
      describe '#minimum_salary_at_least_minimum_payscale' do
        let(:school) { create(:school) }
        let(:job_specification) do
          JobSpecificationForm.new(job_title: 'job title',
                                   job_description: 'description', working_pattern: :full_time,
                                   minimum_salary: 20, maximum_salary: 200, school_id: school.id)
        end

        it 'the minimum salary should be at least equal to the minimum payscale value' do
          expect(job_specification.valid?). to be false
          expect(job_specification.errors.messages[:minimum_salary][0])
            . to eq("must be at least £#{school.minimum_pay_scale_salary}")
        end
      end
    end

    describe '#maximum_salary' do
      let(:school) { create(:school) }
      let(:job_specification) do
        JobSpecificationForm.new(job_title: 'job title',
                                 job_description: 'description', working_pattern: :full_time,
                                 minimum_salary: 28000, maximum_salary: 10000, school_id: school.id)
      end

      it 'the maximum salary should be higher than the minimum salary' do
        expect(job_specification.valid?).to be false
        expect(job_specification.errors.messages[:maximum_salary][0])
          .to eq('must be higher than the minimum salary')
      end
    end
  end

  context 'when all attributes are valid' do
    let(:school) { create(:school) }
    let(:min_pay_scale) { create(:pay_scale) }
    let(:max_pay_scale) { create(:pay_scale) }
    let(:main_subject) { create(:subject) }
    let(:leadership) { create(:leadership) }

    it 'a JobSpecificationForm can be converted to a vacancy' do
      job_specification_form = JobSpecificationForm.new(job_title: 'English Teacher',
                                                        job_description: 'description',
                                                        working_pattern: :full_time,
                                                        minimum_salary: 28000, maximum_salary: 40000,
                                                        benefits: 'benefits', subject_id: main_subject.id,
                                                        min_pay_scale_id: min_pay_scale.id,
                                                        max_pay_scale_id: max_pay_scale.id,
                                                        leadership_id: leadership.id,
                                                        school_id: school.id)

      expect(job_specification_form.valid?).to be true
      expect(job_specification_form.vacancy.job_title).to eq('English Teacher')
      expect(job_specification_form.vacancy.job_description).to eq('description')
      expect(job_specification_form.vacancy.working_pattern).to eq('full_time')
      expect(job_specification_form.vacancy.minimum_salary).to eq('28000')
      expect(job_specification_form.vacancy.maximum_salary).to eq('40000')
      expect(job_specification_form.vacancy.benefits).to eq('benefits')
      expect(job_specification_form.vacancy.min_pay_scale.label).to eq(min_pay_scale.label)
      expect(job_specification_form.vacancy.max_pay_scale.label).to eq(max_pay_scale.label)
      expect(job_specification_form.vacancy.subject.name).to eq(main_subject.name)
      expect(job_specification_form.vacancy.leadership.title).to eq(leadership.title)
    end
  end
end
