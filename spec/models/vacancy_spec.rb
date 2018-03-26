require 'rails_helper'
RSpec.describe Vacancy, type: :model do
  subject { Vacancy.new(school: build(:school)) }
  it { should belong_to(:school) }

  describe 'validations' do
    context 'a new record' do
      it { should validate_presence_of(:working_pattern) }
      it { should validate_presence_of(:job_title) }
      it { should validate_presence_of(:headline) }
      it { should validate_presence_of(:job_description) }
      it { should validate_presence_of(:minimum_salary) }
    end

    context 'a record saved with job spec details' do
      subject do
        Vacancy.create(
          school: create(:school),
          job_title: 'Primary teacher',
          headline: 'We are looking for a great teacher',
          job_description: 'Teach a primary class.',
          minimum_salary: 20_000,
          working_pattern: :full_time
        )
      end
      it { should validate_presence_of(:essential_requirements) }
    end

    context 'a record saved with job spec and candidate spec details, ' \
      'and empty contact_email' do

      subject { build(:vacancy) }
      before { subject.contact_email = '' }

      it 'should validate presence of contact email' do
        expect(subject.valid?).to be_falsy
        expect(subject.errors.messages[:contact_email]).not_to eql([])
      end

      it { should validate_presence_of(:publish_on) }
      it { should validate_presence_of(:expires_on) }
    end

    describe '#minimum_salary_lower_than_maximum' do
      it 'the minimum salary should be less than the maximum salary' do
        vacancy = build(:vacancy, minimum_salary: 20, maximum_salary: 10)

        expect(vacancy.valid?).to be false
        expect(vacancy.errors.messages[:minimum_salary][0]).to eq('must be lower than the maximum salary')
      end
    end

    describe '#working_hours_validation' do
      it 'can not accept non-numeric values' do
        vacancy = build(:vacancy, weekly_hours: 'eight and a half')

        expect(vacancy.valid?).to be(false)
        expect(vacancy.errors.messages[:weekly_hours][0]).to eq('must be a valid number')
      end

      it 'can accept decimal values' do
        vacancy = build(:vacancy, weekly_hours: '0.5')

        expect(vacancy.valid?).to be true
        expect(vacancy.weekly_hours).to eq('0.5')
      end

      it 'must not have a negative value' do
        vacancy = build(:vacancy, weekly_hours: '-5')

        expect(vacancy.valid?).to be false
        expect(vacancy.errors.messages[:weekly_hours][0]).to eq('can\'t be negative')
      end
    end
  end

  describe '#slug' do
    it 'a vacancy slug is not duplicate' do
      green_school = build(:school, name: 'Green school', town: 'Greenway', county: 'Mars')
      blue_school = build(:school, name: 'Blue school')
      first_maths_teacher = create(:vacancy, :published, job_title: 'Maths Teacher', school: blue_school)
      second_maths_teacher = create(:vacancy, :published, job_title: 'Maths Teacher', school: green_school)
      third_maths_teacher = create(:vacancy, :published, job_title: 'Maths Teacher', school: green_school)
      fourth_maths_teacher = create(:vacancy, :published, job_title: 'Maths Teacher', school: green_school)

      expect(first_maths_teacher.slug).to eq('maths-teacher')
      expect(second_maths_teacher.slug).to eq('maths-teacher-green-school')
      expect(third_maths_teacher.slug).to eq('maths-teacher-green-school-greenway-mars')

      expect(fourth_maths_teacher.slug).to include('maths-teacher')
      expect(fourth_maths_teacher.slug).not_to eq('maths-teacher')
      expect(fourth_maths_teacher.slug).not_to eq('maths-teacher-green-school')
      expect(fourth_maths_teacher.slug).not_to eq('maths-teacher-green-school-greenway-mars')
    end
  end

  describe 'applicable scope' do
    it 'should only find current vacancies' do
      expired = build(:vacancy, :expired)
      expired.send :set_slug
      expired.save(validete: false)
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
