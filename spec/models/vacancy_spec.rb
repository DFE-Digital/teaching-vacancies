require 'rails_helper'
RSpec.describe Vacancy, type: :model do
  subject { Vacancy.new(school: build(:school)) }
  it { should belong_to(:school) }

  describe '.public_search' do
    context 'when there were no results' do
      it 'records the event in Rollbar' do
        filters = VacancyFilters.new(keyword: 'a-non-matching-search-term')
        expect(Rollbar).to receive(:log)
          .with(:info,
                'A search returned 0 results',
                location: nil,
                radius: 'km',
                keyword: 'a-non-matching-search-term',
                minimum_salary: nil,
                maximum_salary: nil,
                working_pattern: nil,
                newly_qualified_teacher: nil,
                phase: nil)

        results = Vacancy.public_search(filters: filters, sort: VacancySort.new)

        expect(results.count).to eql(0)
      end
    end
  end

  describe 'validations' do
    context 'a new record' do
      it { should validate_presence_of(:working_pattern) }
      it { should validate_presence_of(:job_title) }
      it { should validate_presence_of(:job_description) }
      it { should validate_presence_of(:minimum_salary) }
    end

    context 'a record saved with job spec details' do
      subject { create(:vacancy) }

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
          .to eq(I18n.t('errors.messages.too_short.other', count: 4))
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
          .to eq(I18n.t('errors.messages.too_long.other', count: 100))
      end
    end

    context 'restrict maximum length of text fields' do
      subject { build(:vacancy, :fail_maximum_validation) }
      before(:each) do
        subject.valid?
      end

      it '#job_description' do
        expect(subject.errors.messages[:job_description].first)
          .to eq(I18n.t('errors.messages.too_long.other', count: 50_000))
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

    context '#minimum_salary and #maximum_salary combined validations' do
      it 'present minimum_salary and no maximum_salary' do
        job = build(:vacancy, minimum_salary: '20', maximum_salary: nil)

        expect(job.valid?).to be true
        expect(job.errors.messages[:minimum_salary]).to be_empty
        expect(job.errors.messages[:maximum_salary]).to be_empty
      end

      it 'no minimum_salary and no maximum_salary set' do
        job = build(:vacancy, minimum_salary: nil, maximum_salary: nil)

        expect(job.valid?).to be false
        expect(job.errors.messages[:minimum_salary]).to eq(['can\'t be blank'])
        expect(job.errors.messages[:maximum_salary]).to be_empty
      end

      it 'no minimum_salary and invalid maximum_salary' do
        job = build(:vacancy, minimum_salary: nil, maximum_salary: 'not a number')

        expect(job.valid?).to be false
        expect(job.errors.messages[:minimum_salary]).to eq(['can\'t be blank'])
        expect(job.errors.messages[:maximum_salary]).to be_empty
      end

      it 'invalid minimum_salary and no maximum_salary' do
        job = build(:vacancy, minimum_salary: 'A20000', maximum_salary: nil)

        expect(job.valid?).to be false
        expect(job.errors.messages[:minimum_salary])
          .to eq(['must be entered in one of the following formats: 25000 or 25000.00'])
        expect(job.errors.messages[:maximum_salary]).to be_empty
      end

      it 'invalid minimum_salary and invalid maximum_salary' do
        job = build(:vacancy, minimum_salary: 'A20000', maximum_salary: '20K')

        expect(job.valid?).to be false
        expect(job.errors.messages[:minimum_salary])
          .to eq(['must be entered in one of the following formats: 25000 or 25000.00'])
        expect(job.errors.messages[:maximum_salary]).to be_empty
      end

      it 'invalid minimum_salary and valid maximum_salary' do
        job = build(:vacancy, minimum_salary: 'A20000', maximum_salary: '20000')

        expect(job.valid?).to be false
        expect(job.errors.messages[:minimum_salary])
          .to eq(['must be entered in one of the following formats: 25000 or 25000.00'])
        expect(job.errors.messages[:maximum_salary]).to be_empty
      end

      it 'valid minimum_salary and invalid maximum_salary' do
        job = build(:vacancy, minimum_salary: '20000', maximum_salary: 'A20000')

        expect(job.valid?).to be false
        expect(job.errors.messages[:minimum_salary]).to be_empty
        expect(job.errors.messages[:maximum_salary])
          .to eq(['must be entered in one of the following formats: 25000 or 25000.00'])
      end

      it 'valid minimum_salary and greater than allowed maximum_salary' do
        job = build(:vacancy, minimum_salary: '20000', maximum_salary: 200000000000)

        expect(job).to_not be_valid
        expect(job.errors.messages[:minimum_salary]).to be_empty
        expect(job.errors.messages[:maximum_salary])
          .to eq(['must not be more than £200000'])
      end

      it 'greater than allowed minimum_salary and no maximum_salary' do
        job = build(:vacancy, minimum_salary: '20000000000000', maximum_salary: 200000000000)

        expect(job).to_not be_valid
        expect(job.errors.messages[:minimum_salary])
          .to eq(['must not be more than £200000'])
        expect(job.errors.messages[:maximum_salary]).to be_empty
      end
    end

    context 'a record saved with job spec and candidate spec details, ' \
      'and empty contact_email' do

      subject { build(:vacancy, status: :draft) }
      before { subject.contact_email = '' }

      it 'should validate presence of contact email' do
        expect(subject.valid?).to be_falsy
        expect(subject.errors.messages[:contact_email]).not_to eql([])
      end

      it { should validate_presence_of(:publish_on) }
      it { should validate_presence_of(:expires_on) }
    end

    describe '#maximum_salary_greater_than_minimum' do
      it 'the minimum salary should be less than the maximum salary' do
        vacancy = build(:vacancy, minimum_salary: 20, maximum_salary: 10)

        expect(vacancy.valid?).to be false
        expect(vacancy.errors.messages[:maximum_salary]).to eq(['must be higher than the minimum salary'])
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

  describe 'friendly_id generated slug' do
    context '#slug' do
      it 'the slug cannot be duplicate' do
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

    context '#refresh_slug' do
      it 'resets the current slug by accessing a friendly_id private method' do
        job = create(:vacancy, slug: 'the-wrong-slug')
        job.job_title = 'CS Teacher'
        job.refresh_slug

        expect(job.slug).to eq('cs-teacher')
      end
    end

    context '#listed?' do
      it 'returns true if the vacancy is currently listed' do
        job = create(:vacancy, :published)

        expect(job.listed?).to be true
      end

      it 'returns false if the vacancy is not yet listed' do
        job = build(:vacancy, :published, slug: 'value', publish_on: Time.zone.tomorrow)
        job.save(validate: false)

        expect(job.listed?).to be false
      end
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

    describe '#listed' do
      it 'retrieves  vacancies that have a status of :published and a future publish_on date' do
        published = create_list(:vacancy, 5, :published)
        create_list(:vacancy, 3, :future_publish)
        create_list(:vacancy, 4, :trashed)

        expect(Vacancy.listed.count).to eq(published.count)
      end
    end

    describe '#published_on_count(date)' do
      it 'retrieves vacancies listed on the specified date' do
        published_today = create_list(:vacancy, 3, :published_slugged)
        published_yesterday = build_list(:vacancy, 2, :published_slugged, publish_on: 1.day.ago)
        published_yesterday.each { |v| v.save(validate: false) }
        published_the_other_day = build_list(:vacancy, 1, :published_slugged, publish_on: 2.days.ago)
        published_the_other_day.each { |v| v.save(validate: false) }
        published_some_other_day = build_list(:vacancy, 6, :published_slugged, publish_on: 1.month.ago)
        published_some_other_day.each { |v| v.save(validate: false) }

        expect(Vacancy.published_on_count(Time.zone.today)).to eq(published_today.count)
        expect(Vacancy.published_on_count(1.day.ago)).to eq(published_yesterday.count)
        expect(Vacancy.published_on_count(2.days.ago)).to eq(published_the_other_day.count)
        expect(Vacancy.published_on_count(1.month.ago)).to eq(published_some_other_day.count)
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

  describe '#to_row' do
    let(:vacancy) { build(:vacancy) }
    before do
      vacancy.save!
      allow(vacancy).to receive(:id).and_return('123a-456b-789c')
      allow(vacancy).to receive(:slug).and_return('my-new-vacancy')
    end

    it 'creates a CSV row representation of the vacancy' do
      expect(vacancy.to_row).to be_an(Array)
      expect(vacancy.to_row).to include('123a-456b-789c', 'my-new-vacancy', 'published')
    end
  end
end
