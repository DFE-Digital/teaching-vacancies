require 'rails_helper'

RSpec.describe JobPosting do
  let(:data) do
    {
      '@type' => 'JobPosting',
      'title' => 'Teacher of English',
      'occupationalCategory' => 'TEACHER, SEN_SPECIALIST',
      'salary' => 'Pay scale 1 to Pay scale 2',
      'jobBenefits' => '<p>This is an exceptional opportunity to make a difference within a positive environment.</p>',
      'datePosted' => date_posted,
      'description' => '<p>We are seeking an inspirational, dynamic and industrious Teacher of English</p>',
      'educationRequirements' => '<p>Relevant degree</p>',
      'qualifications' => '<p>Qualified Teacher Status</p>',
      'experienceRequirements' => '<p>Excellent classroom practitioner</p>',
      'employmentType' => 'FULL_TIME, PART_TIME',
      'industry' => 'Education',
      'url' => 'https://teaching-vacancies.service.gov.uk/jobs/teacher-of-english-gosforth-academy',
      'hiringOrganization' => {
        '@type' => 'School',
        'name' => 'Gosforth Academy',
        'identifier' => '136352',
        'description' => '<p>Best school ever</p>'
      },
      'validThrough' => valid_through,
      'workHours' => '37.5',
      'aboutSchool' => 'Some information about the school'
    }
  end
  let(:school_by_urn) { build(:school, urn: '136352') }
  let(:job_posting) { JobPosting.new(data) }
  let(:date_posted) { Time.zone.now.iso8601 }
  let(:valid_through) { 1.week.from_now.iso8601 }

  describe '#to_vacancy' do
    before { allow(School).to receive(:find_by).with(urn: '136352').and_return(school_by_urn) }
    subject(:to_vacancy) { job_posting.to_vacancy }

    it { is_expected.to be_a(Vacancy) }
    it { is_expected.to be_valid }

    context 'when the school urn is not found' do
      let(:school_by_urn) { nil }
      let(:random_school) { build(:school) }

      it 'assigns a random school' do
        allow(School).to receive(:offset).and_return(double(first: random_school))
        vacancy = to_vacancy
        expect(vacancy.school).to eql(random_school)
      end
    end

    context 'when the publish date is in the past' do
      let(:date_posted) { 1.day.ago.iso8601 }

      it 'sets the publish_on field to today' do
        vacancy = to_vacancy
        expect(vacancy.publish_on).to eql(Time.zone.today)
      end
    end

    context 'when the expiry date is in the past' do
      let(:valid_through) { 1.week.ago.iso8601 }

      it 'sets the expires_on field to a date in the future' do
        vacancy = to_vacancy
        expect(vacancy.expires_on).to eql(4.months.from_now.to_date)
      end
    end
  end
end
