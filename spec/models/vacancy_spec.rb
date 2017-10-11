require 'rails_helper'

RSpec.describe Vacancy, type: :model do
  subject { Vacancy.new(school: build(:school)) }
  it { should belong_to(:school) }
  it { should validate_presence_of(:job_title) }
  it { should validate_presence_of(:headline) }
  it { should validate_presence_of(:job_description) }
  it { should validate_presence_of(:minimum_salary) }
  it { should validate_presence_of(:essential_requirements) }
  it { should validate_presence_of(:working_pattern) }
  it { should validate_presence_of(:publish_on) }
  it { should validate_presence_of(:expires_on) }

  describe "validations", wip: true do
    describe "#minimum_salary_lower_than_maximum" do
      it "the minimum salary should be less than the maximum salary" do
        vacancy = build(:vacancy, minimum_salary: 20, maximum_salary: 10)

        expect(vacancy.valid?).to be false
        expect(vacancy.errors.messages[:minimum_salary][0]).to eq("must be lower than the maximum salary")
      end
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

  describe 'delegate school_name' do
    it 'should return the school name for the vacancy' do
      school = create(:school, name: 'St James School')
      vacancy = create(:vacancy, school: school)

      expect(vacancy.school_name).to eq('St James School')
    end
  end

end
