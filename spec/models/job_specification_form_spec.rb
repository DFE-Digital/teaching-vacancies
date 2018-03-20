require 'rails_helper'
RSpec.describe JobSpecificationForm, type: :model do
  subject { JobSpecificationForm.new({}) }

  describe 'validations' do
    it { should validate_presence_of(:job_title) }
    it { should validate_presence_of(:headline) }
    it { should validate_presence_of(:job_description) }
    it { should validate_presence_of(:minimum_salary) }
    it { should validate_presence_of(:working_pattern) }

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
