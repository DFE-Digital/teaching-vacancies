require 'rails_helper'
RSpec.feature 'Viewing a single published vacancy' do
  scenario 'Published vacancies are viewable' do
    published_vacancy = VacancyPresenter.new(create(:vacancy, :published))

    visit vacancy_path(published_vacancy)

    expect(page).to have_content(published_vacancy.job_title)
    expect(page).to have_content(published_vacancy.headline)
    expect(page).to have_content(published_vacancy.job_description)
    expect(page).to have_content(published_vacancy.salary_range)
  end

  scenario 'Unpublished vacancies are not viewable' do
    draft_vacancy = create(:vacancy, :draft)

    visit vacancy_path(draft_vacancy)

    expect(page).to have_content('Page not found')
    expect(page).to_not have_content(draft_vacancy.job_title)
  end

  scenario 'Vacancy slugs are not duplicated' do
    first_maths_teacher = create(:vacancy, :published, job_title: 'Maths Teacher',
                                                       school: build(:school, name: 'Blue School'))
    second_maths_teacher = create(:vacancy, :published, job_title: 'Maths Teacher',
                                                        school: build(:school, name: 'Green school'))
    third_maths_teacher = create(:vacancy, :published, job_title: 'Maths Teacher',
                                                       school: build(:school, name: 'Green school',
                                                                              town: 'Greenway', county: 'Mars'))
    fourth_maths_teacher = create(:vacancy, :published, job_title: 'Maths Teacher',
                                                        school: build(:school, name: 'Green school',
                                                                               town: 'Greenway', county: 'Mars'))

    expect(first_maths_teacher.slug).to eq('maths-teacher')
    expect(second_maths_teacher.slug).to eq('maths-teacher-green-school')
    expect(third_maths_teacher.slug).to eq('maths-teacher-green-school-greenway-mars')

    expect(fourth_maths_teacher.slug).to have_content('maths-teacher')
    expect(fourth_maths_teacher.slug).not_to eq('maths-teacher')
    expect(fourth_maths_teacher.slug).not_to eq('maths-teacher-green-school')
    expect(fourth_maths_teacher.slug).not_to eq('maths-teacher-green-school-greenway-mars')
  end

  scenario 'Expired vacancies display a warning message' do
    current_vacancy = create(:vacancy)
    expired_vacancy = create(:vacancy, :expired)

    visit vacancy_path(current_vacancy)
    expect(page).to have_no_content('This vacancy has expired')

    visit vacancy_path(expired_vacancy)
    expect(page).to have_content('This vacancy has expired')
  end

  scenario 'A single vacancy must  contain JobPosting schema.org mark up', elasticsearch: true do
    vacancy = create(:vacancy, :job_schema)

    Vacancy.__elasticsearch__.client.indices.flush
    visit vacancy_path(vacancy)

    expect(script_tag_content(wrapper_class: '.jobref')).to eq(vacancy_json_ld(vacancy).to_json)
  end
end
