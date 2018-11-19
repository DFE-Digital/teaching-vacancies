require 'rails_helper'

RSpec.feature 'Searching vacancies by keyword' do
  describe 'searchable fields' do
    context '#job_title' do
      scenario 'exact match', elasticsearch: true do
        vacancy = create(:vacancy, job_title: 'Maths Teacher')

        Vacancy.__elasticsearch__.client.indices.flush

        visit jobs_path

        expect(page.find('.vacancy:eq(1)')).to have_content(vacancy.job_title)

        within '.filters-form' do
          fill_in 'keyword', with: vacancy.job_title
          page.find('.govuk-button[type=submit]').click
        end

        expect(page.find('.vacancy:eq(1)')).to have_content(vacancy.job_title)
      end

      scenario 'partial match', elasticsearch: true do
        vacancy = create(:vacancy, job_title: 'Maths Teacher')

        Vacancy.__elasticsearch__.client.indices.flush

        visit jobs_path

        expect(page.find('.vacancy:eq(1)')).to have_content(vacancy.job_title)

        within '.filters-form' do
          fill_in 'keyword', with: 'Math'
          page.find('.govuk-button[type=submit]').click
        end

        expect(page.find('.vacancy:eq(1)')).to have_content(vacancy.job_title)
      end
    end

    scenario '#subject', elasticsearch: true do
      arts_vacancy = create(:vacancy, job_title: 'Arts Teacher', subject: create(:subject, name: 'Arts'),
                                      first_supporting_subject: create(:subject, name: 'English'))
      maths_vacancy = create(:vacancy, job_title: 'Teacher Bar', subject: create(:subject, name: 'Maths'))
      english_vacancy = create(:vacancy, job_title: 'Teacher Foo', subject: create(:subject, name: 'English'))

      Vacancy.__elasticsearch__.client.indices.flush

      visit jobs_path

      expect(page).to have_content(arts_vacancy.job_title)
      expect(page).to have_content(maths_vacancy.job_title)
      expect(page).to have_content(english_vacancy.job_title)

      within '.filters-form' do
        fill_in 'keyword', with: 'English'
        page.find('.govuk-button[type=submit]').click
      end

      expect(page).to have_content(arts_vacancy.job_title)
      expect(page).to have_content(english_vacancy.job_title)
      expect(page).not_to have_content(maths_vacancy.job_title)
    end
  end

  describe 'does not match' do
    scenario '#description', elasticsearch: true do
      vacancy = create(:vacancy, job_description: 'Opening has for an outstanding teacher.')

      Vacancy.__elasticsearch__.client.indices.flush

      visit jobs_path

      expect(page.find('.vacancy:eq(1)')).to have_content(vacancy.job_title)

      within '.filters-form' do
        fill_in 'keyword', with: 'standing'
        page.find('.govuk-button[type=submit]').click
      end

      expect(page).to_not have_content(vacancy.job_title)
    end
  end

  context 'fuzzy search' do
    scenario 'finds on any searchable word with a single typo', elasticsearch: true do
      vacancy = create(:vacancy, job_title: 'Maths Teacher')

      Vacancy.__elasticsearch__.client.indices.flush

      visit jobs_path

      expect(page.find('.vacancy:eq(1)')).to have_content(vacancy.job_title)

      within '.filters-form' do
        fill_in 'keyword', with: 'Maht'
        page.find('.govuk-button[type=submit]').click
      end

      expect(page.find('.vacancy:eq(1)')).to have_content(vacancy.job_title)
    end
  end

  context 'stopword search' do
    scenario 'Does not include results with words removed from the index in their title', elasticsearch: true do
      create(:vacancy, :expire_tomorrow, job_title: 'Maths Teacher', subject: nil)
      art_teacher = build(:vacancy, :expire_tomorrow,
                          slug: 'art-teacher',
                          job_title: 'Art Teacher',
                          subject: nil,
                          publish_on: Time.zone.yesterday)
      art_teacher.save(validate: false)
      geography = build(:vacancy,
                        slug: 'geography-teacher',
                        job_title: 'Geography Teacher',
                        publish_on: Time.zone.yesterday - 1.day,
                        expires_on: Time.zone.today + 2.days,
                        subject: create(:subject, name: 'Art'))
      geography.save(validate: false)
      create(:vacancy, :expire_tomorrow, job_title: 'Part time Geography Teacher', subject: nil)
      create(:vacancy, :expire_tomorrow, job_title: 'Chemistry Full time', subject: nil)

      Vacancy.__elasticsearch__.client.indices.flush

      visit jobs_path

      expect(page.all('.vacancy', count: 5)).to_not be_empty

      within '.filters-form' do
        fill_in 'keyword', with: 'Art'
        page.find('.govuk-button[type=submit]').click
      end

      expect(page.find('.vacancy:eq(1)')).to have_content('Art Teacher')
      expect(page.find('.vacancy:eq(2)')).to have_content('Geography Teacher')
      expect(page).to have_content('2 jobs match your search.')

      within '.filters-form' do
        fill_in 'keyword', with: 'Atr'
        page.find('.govuk-button[type=submit]').click
      end

      expect(page.find('.vacancy:eq(1)')).to have_content('Art Teacher')
      expect(page.find('.vacancy:eq(2)')).to have_content('Geography Teacher')
      expect(page).to have_content('2 jobs match your search.')

      within '.filters-form' do
        fill_in 'keyword', with: 'Part'
        page.find('.govuk-button[type=submit]').click
      end
      expect(page).to have_content('0 jobs match your search.')

      within '.filters-form' do
        fill_in 'keyword', with: 'time'
        page.find('.govuk-button[type=submit]').click
      end
      expect(page).to have_content('0 jobs match your search.')
    end
  end

  context 'search parameters are persisted on navigation' do
    scenario 'back link perists search params' do
      create(:vacancy, job_title: 'Maths Teacher')

      Vacancy.__elasticsearch__.client.indices.flush

      visit jobs_path

      within '.filters-form' do
        fill_in 'keyword', with: 'Math'
        page.find('.govuk-button[type=submit]').click
      end

      page.find('.view-vacancy-link').click
      expect(page).to have_content('Maths Teacher')

      page.find('.govuk-back-link').click
      expect(page.current_url).to include('keyword=Math')
    end
  end
end
