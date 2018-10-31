require 'rails_helper'
RSpec.describe 'rake vacancies:data:update', type: :task do
  include ActionView::Helpers::SanitizeHelper

  let(:data) { YAML.load_file(Rails.root.join('lib', 'tasks', 'vacancies_to_update.yaml'))['vacancies']['update'] }

  it 'updates the information of a given vacancy' do
    slug = 'teacher-of-science-the-english-martyrs-school-and-sixth-form-college-hartlepool'
    create(:vacancy, job_title: 'Teacher of Science',
                     job_description: 'teacher of science description',
                     slug: slug,
                     expires_on: Time.zone.now + 1.year)

    other_slug = 'teacher-of-english-norham-high-school'
    create(:vacancy, job_title: 'Teacher of Science',
                     experience: 'sample experience',
                     benefits: 'sample benefits',
                     slug: other_slug)

    nqt_slug = 'teacher-of-music-maternity-cover-0-6'
    create(:vacancy, job_title: 'Teacher of Music',
                     newly_qualified_teacher: false,
                     slug: nqt_slug)

    task.invoke

    index = 0 # position in data file
    vacancy = Vacancy.find_by(slug: slug)
    expect(vacancy.job_title).to eq(data[index]['job_title'])
    expect(vacancy.job_description).to eq(sanitize(data[index]['job_description']))
    expect(vacancy.expires_on).to eq(Date.parse('12/10/2018'))

    index = 1
    other_vacancy = Vacancy.find_by(slug: other_slug)
    expect(other_vacancy.experience).to eq(sanitize(data[index]['experience']))
    expect(other_vacancy.benefits).to eq(sanitize(data[index]['benefits']))

    nqt_vacancy = Vacancy.find_by(slug: nqt_slug)
    expect(nqt_vacancy.newly_qualified_teacher).to eq(true)
  end
end

RSpec.describe 'rake vacancies:data:delete', type: :task do
  context 'Deleting scraped vacancies' do
    it 'deletes vacancies' do
      slug = 'class-teacher-primary'
      create(:vacancy, slug: 'class-teacher-primary')

      task.invoke

      expect(Vacancy.find_by(slug: slug)).to eq(nil)
    end
  end
end
