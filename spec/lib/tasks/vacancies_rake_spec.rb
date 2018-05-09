require 'rails_helper'
RSpec.describe ':vacancies' do
  include ActionView::Helpers::SanitizeHelper

  before(:all) do
    TeacherVacancyService::Application.load_tasks
  end

  let(:data) { YAML.load_file(Rails.root.join('lib', 'tasks', 'vacancies_to_update.yaml'))['vacancies']['update'] }

  context 'Updating scraped vacancies' do
    it 'updates the information of a given vacancy' do
      art = create(:subject, name: 'Art')
      mps = create(:pay_scale, label: 'Main pay range 1')
      ups = create(:pay_scale, label: 'Upper pay range 3')
      create(:vacancy, slug: 'teacher-of-a-level-chemistry', job_title: 'Chemistry teacher',
                       job_description: 'Old description', experience: 'Old experience')
      create(:vacancy, slug: 'teacher-of-technology-and-art-part-time-temporary', working_pattern: 'full_time',
                       subject: nil)
      create(:vacancy, slug: 'teacher-of-french', min_pay_scale: nil)
      create(:vacancy, slug: 'teacher-of-maths-maternity-cover', job_title: 'Another french teacher',
                       updated_at: Time.zone.now + 2.minutes)
      create(:vacancy, slug: 'teaching-assistants', working_pattern: 'part_time')

      Rake::Task['vacancies:data:update'].invoke
      index = 20 # position in data file

      vacancy = Vacancy.find_by(slug: 'teacher-of-a-level-chemistry')
      other_vacancy = Vacancy.find_by(slug: 'teacher-of-technology-and-art-part-time-temporary')
      pay_scale_vacancy = Vacancy.find_by(slug: 'teacher-of-french')
      edited_vacancy = Vacancy.find_by(slug: 'teacher-of-maths-maternity-cover')
      reset_working_pattern = Vacancy.find_by(slug: 'teaching-assistants')

      expect(vacancy.experience).to eq(sanitize(data[index]['experience']))
      expect(vacancy.job_title).to eq(data[index]['job_title'])
      expect(vacancy.job_description).to eq(sanitize(data[index]['job_description']))
      expect(vacancy.starts_on).to eq(Date.parse(data[index]['starts_on']))
      expect(vacancy.ends_on).to eq(Date.parse(data[index]['ends_on']))
      expect(other_vacancy.working_pattern).to eq('part_time')
      expect(other_vacancy.subject).to eq(art)
      expect(pay_scale_vacancy.min_pay_scale).to eq(mps)
      expect(pay_scale_vacancy.max_pay_scale).to eq(ups)
      expect(edited_vacancy.job_title).to eq('Another french teacher')
      expect(reset_working_pattern.working_pattern).to eq(nil)
    end
  end

  context 'Deleting scraped vacancies' do
    it 'deletes vacancies' do
      slug = 'class-teacher-primary'
      create(:vacancy, slug: 'class-teacher-primary')

      Rake::Task['vacancies:data:delete'].invoke
      expect(Vacancy.find_by(slug: slug)).to eq(nil)
    end
  end
end
