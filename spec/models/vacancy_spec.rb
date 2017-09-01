require 'rails_helper'

RSpec.describe Vacancy do
  describe 'validations' do
    it 'has to have a job title' do
      expect(Vacancy.new).to have(1).error_on(:job_title)
    end
    it 'has to have a headline' do
      expect(Vacancy.new).to have(1).error_on(:headline)
    end
    it 'has to have a slug' do
      expect(Vacancy.new).to have(1).error_on(:slug)
    end
    it 'has to have a job description' do
      expect(Vacancy.new).to have(1).error_on(:job_description)
    end
    it 'has to have a minimum salary' do
      expect(Vacancy.new).to have(1).error_on(:minimum_salary)
    end
    it 'has to have essential requirements' do
      expect(Vacancy.new).to have(1).error_on(:essential_requirements)
    end
    it 'has to have a working pattern' do
      expect(Vacancy.new).to have(1).error_on(:working_pattern)
    end
    it 'has to have publication date' do
      expect(Vacancy.new).to have(1).error_on(:publish_on)
    end
    it 'has to have an expiry date' do
      expect(Vacancy.new).to have(1).error_on(:expires_on)
    end
  end

  describe 'applicable scope' do
    it 'should only find current vacancies' do
      expired = create(:vacancy, expires_on: 1.day.ago)
      expires_today = create(:vacancy, expires_on: Time.zone.today)
      expires_future = create(:vacancy, expires_on: 3.months.from_now)

      results = Vacancy.applicable
      expect(results).to include(expires_today)
      expect(results).to include(expires_future)
      expect(results).to_not include(expired)
    end
  end

  describe '#location' do
    it 'should return a comma separated location of the school' do
      school = create(:school, name: 'Acme School', town: 'Acme', county: 'Kent')
      vacancy = create(:vacancy, school: school)
      expect(vacancy.location).to eq('Acme School, Acme, Kent')
    end

    context 'when one of the properties is empty' do
      it 'should not include that property' do
        school = create(:school, name: 'Acme School', town: '', county: 'Kent')
        vacancy = create(:vacancy, school: school)
        expect(vacancy.location).to eq('Acme School, Kent')
      end
    end
  end

  describe '#salary_range' do
    it 'should return the formatted minimum to maximum salary' do
      vacancy = create(:vacancy, minimum_salary: 30000, maximum_salary: 40000)
      expect(vacancy.salary_range).to eq('£30,000 - £40,000')
    end

    context 'when no maximum salary is set' do
      it 'should just return the minimum salary' do
        vacancy = create(:vacancy, minimum_salary: 20000, maximum_salary: nil)
        expect(vacancy.salary_range).to eq('£20,000')
      end
    end
  end
end
