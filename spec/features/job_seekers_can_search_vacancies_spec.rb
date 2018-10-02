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
      vacancy = create(:vacancy, job_title: 'Teacher Foo', subject: create(:subject, name: 'English'))

      Vacancy.__elasticsearch__.client.indices.flush

      visit jobs_path

      expect(page.find('.vacancy:eq(1)')).to have_content(vacancy.job_title)

      within '.filters-form' do
        fill_in 'keyword', with: 'English'
        page.find('.govuk-button[type=submit]').click
      end

      expect(page.find('.vacancy:eq(1)')).to have_content(vacancy.job_title)
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
end
