require 'rails_helper'
RSpec.describe Vacancy, type: :model do
  subject { Vacancy.new(school: build(:school)) }
  it { should belong_to(:school) }

  describe 'validations' do
    context 'a new record' do
      it { should validate_presence_of(:working_pattern) }
      it { should validate_presence_of(:job_title) }
      it { should validate_presence_of(:job_description) }
      it { should validate_presence_of(:minimum_salary) }
    end

    context 'a record saved with job spec details' do
      subject do
        Vacancy.create(
          school: create(:school),
          job_title: 'Primary teacher',
          job_description: 'Teach a primary class.',
          minimum_salary: 20_000,
          working_pattern: :full_time
        )
      end
      it { should validate_presence_of(:education) }
      it { should validate_presence_of(:qualifications) }
      it { should validate_presence_of(:experience) }
    end

    context 'set minimum length of mandatory fields' do
      subject { build(:vacancy, :fail_minimum_validation) }
      before(:each) do
        subject.valid?
      end

      it '#job_title' do
        expect(subject.errors.messages[:job_title].first)
          .to eq(I18n.t('errors.messages.too_short.other', count: 10))
      end

      it '#job_description' do
        expect(subject.errors.messages[:job_description].first)
          .to eq(I18n.t('errors.messages.too_short.other', count: 10))
      end

      it '#experience' do
        expect(subject.errors.messages[:experience].first)
          .to eq(I18n.t('errors.messages.too_short.other', count: 10))
      end

      it '#education' do
        expect(subject.errors.messages[:education].first)
          .to eq(I18n.t('errors.messages.too_short.other', count: 10))
      end

      it '#qualifications' do
        expect(subject.errors.messages[:qualifications].first)
          .to eq(I18n.t('errors.messages.too_short.other', count: 10))
      end
    end

    context 'restrict maximum length of string fields' do
      subject { build(:vacancy, :fail_maximum_validation) }
      before(:each) do
        subject.valid?
      end

      it '#job_title' do
        expect(subject.errors.messages[:job_title].first)
          .to eq(I18n.t('errors.messages.too_long.other', count: 50))
      end
    end

    context 'restrict maximum length of text fields' do
      subject { build(:vacancy, :fail_maximum_validation) }
      before(:each) do
        subject.valid?
      end

      it '#job_description' do
        expect(subject.errors.messages[:job_description].first)
          .to eq(I18n.t('errors.messages.too_long.other', count: 1000))
      end

      it '#experience' do
        expect(subject.errors.messages[:experience].first)
          .to eq(I18n.t('errors.messages.too_long.other', count: 1000))
      end

      it '#education' do
        expect(subject.errors.messages[:education].first)
          .to eq(I18n.t('errors.messages.too_long.other', count: 1000))
      end

      it '#qualifications' do
        expect(subject.errors.messages[:qualifications].first)
          .to eq(I18n.t('errors.messages.too_long.other', count: 1000))
      end
    end

    context 'restrict maximum length of integer fields' do
      subject { build(:vacancy, :fail_maximum_validation) }
      before(:each) do
        subject.valid?
      end

      it '#minimum_salary' do
        expect(subject.errors.messages[:minimum_salary].first)
          .to eq('must be less than or equal to £2,147,483,647.00')
      end

      it '#maximum_salary' do
        expect(subject.errors.messages[:maximum_salary].first)
          .to eq('must be less than or equal to £2,147,483,647.00')
      end
    end

    context '#minimum_salary' do
      it 'does not allow the pound sign' do
        vacancy = build(:vacancy, minimum_salary: '£123.33')
        vacancy.valid?

        expect(vacancy.errors.messages[:minimum_salary].first).to eq(I18n.t('errors.messages.salary.invalid_format'))
      end

      it 'does not allow commas' do
        vacancy = build(:vacancy, minimum_salary: '300,33')
        vacancy.valid?

        expect(vacancy.errors.messages[:minimum_salary].first).to eq(I18n.t('errors.messages.salary.invalid_format'))
      end

      it 'does not allow fullstops if the decimal separation point is wrong' do
        vacancy = build(:vacancy, minimum_salary: '300.330')
        vacancy.valid?

        expect(vacancy.errors.messages[:minimum_salary].first).to eq(I18n.t('errors.messages.salary.invalid_format'))
      end

      it 'does not allow any non numeric characters' do
        vacancy = build(:vacancy, minimum_salary: 'A300330')
        vacancy.valid?

        expect(vacancy.errors.messages[:minimum_salary].first).to eq(I18n.t('errors.messages.salary.invalid_format'))
      end

      it 'allows fullstops if the decimal separation point is correct' do
        vacancy = build(:vacancy, minimum_salary: '30000.50')

        expect(vacancy).to be_valid
      end

      it 'accepts integer numbers' do
        vacancy = build(:vacancy, minimum_salary: '45000')

        expect(vacancy).to be_valid
      end
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

  context 'actions' do
    describe '#trash!' do
      it 'sets a vacancy to trashed and does not retrieve it in the applicable scope' do
        vacancies = create_list(:vacancy, 4)
        vacancies.last.trashed!
        expect(Vacancy.active.count).to eq(3)
        vacancies.first.trashed!
        expect(Vacancy.active.count).to eq(2)
      end
    end
  end

  context 'scopes' do
    describe '#applicable' do
      it 'finds current vacancies' do
        expired = build(:vacancy, :expired)
        expired.send :set_slug
        expired.save(validate: false)
        expires_today = create(:vacancy, expires_on: Time.zone.today)
        expires_future = create(:vacancy, expires_on: 3.months.from_now)

        results = Vacancy.applicable
        expect(results).to include(expires_today)
        expect(results).to include(expires_future)
        expect(results).to_not include(expired)
      end
    end

    describe '#active' do
      it 'retrieves active vacancies that have a status of :draft or :published' do
        draft = create_list(:vacancy, 2, :draft)
        published = create_list(:vacancy, 5, :published)
        create_list(:vacancy, 4, :trashed)

        expect(Vacancy.active.count).to eq(draft.count + published.count)
      end
    end
  end

  describe 'delegate school_name' do
    it 'should return the school name for the vacancy' do
      school = create(:school, name: 'St James School')
      vacancy = create(:vacancy, school: school)

      expect(vacancy.school_name).to eq('St James School')
    end
  end

  describe '#application_link' do
    it 'returns the url' do
      vacancy = create(:vacancy, application_link: 'https://example.com')
      expect(vacancy.application_link).to eql('https://example.com')
    end

    context 'when a protocol was not provided' do
      it 'returns an absolute url with `http` as the protocol' do
        vacancy = create(:vacancy, application_link: 'example.com')
        expect(vacancy.application_link).to eql('http://example.com')
      end
    end

    context 'when only the `www` sub domain was provided' do
      it 'returns an absolute url with `http` as the protocol' do
        vacancy = create(:vacancy, application_link: 'www.example.com')
        expect(vacancy.application_link).to eql('http://www.example.com')
      end
    end
  end

  context 'Content sanitization' do
    it '#job_description' do
      html = '<p> a paragraph <a href=\'link\'>with a link</a></p><br>'
      vacancy = build(:vacancy, job_description: html)

      sanitized_html = '<p> a paragraph with a link</p><br>'
      expect(vacancy.job_description).to eq(sanitized_html)
    end

    it '#job_title' do
      title = '<strong>School teacher </strong>'
      vacancy = build(:vacancy, job_title: title)

      sanitized_title = 'School teacher '
      expect(vacancy.job_title).to eq(sanitized_title)
    end

    it '#benefits' do
      benefits = '<ul><li><a href="">Gym membership</a></li></ul>'
      vacancy = build(:vacancy, benefits: benefits)

      sanitized_benefits = '<ul><li>Gym membership</li></ul>'
      expect(vacancy.benefits).to eq(sanitized_benefits)
    end

    it '#experience' do
      experience = '<strong>2 years experience</strong><script>'
      vacancy = build(:vacancy, experience: experience)

      sanitized_experience = '<strong>2 years experience</strong>'
      expect(vacancy.experience).to eq(sanitized_experience)
    end

    it '#qualifications' do
      qualifications = '<em>Degree in Teaching</em><br><a href="a-link">more info</a>'
      vacancy = build(:vacancy, qualifications: qualifications)

      sanitized_qualifications = '<em>Degree in Teaching</em><br>more info'
      expect(vacancy.qualifications).to eq(sanitized_qualifications)
    end

    it '#education' do
      education = '<p><a href="http://university-of-london">University of London</a></p>'
      vacancy = build(:vacancy, education: education)

      sanitized_education = '<p>University of London</p>'
      expect(vacancy.education).to eq(sanitized_education)
    end
  end
end
