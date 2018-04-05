require 'rails_helper'
RSpec.feature 'Hiring staff can edit a vacancy' do
  let(:school) { create(:school) }

  before(:each) do
    stub_hiring_staff_auth(urn: school.urn)
  end

  context 'attempting to edit a draft vacancy' do
    scenario 'redirects to the review vacancy page' do
      vacancy = create(:vacancy, :draft, school: school)
      visit edit_school_vacancy_path(school_id: school.id, id: vacancy.id)

      expect(page).to have_content("Review the vacancy for #{school.name}")
    end
  end

  context 'navigation' do
    scenario 'links to the school page' do
      vacancy = create(:vacancy, :published, school: school)
      visit edit_school_vacancy_path(school_id: school.id, id: vacancy.id)

      click_on school.name
      expect(page).to have_content("Vacancies at #{school.name}")
    end
  end

  context 'editing a published vacancy' do
    scenario 'takes your to the edit page' do
      vacancy = create(:vacancy, :published, school: school)
      visit edit_school_vacancy_path(school_id: school.id, id: vacancy.id)

      expect(page).to have_content("Edit vacancy for #{school.name}")
    end

    context '#job_specification' do
      scenario 'can not be edited when validation fails' do
        vacancy = create(:vacancy, :published, school: school)
        visit edit_school_vacancy_path(school_id: school.id, id: vacancy.id)

        expect(page).to have_content("Edit vacancy for #{school.name}")
        click_link_in_container_with_text('Job title')

        fill_in 'job_specification_form[job_title]', with: ''
        click_on 'Update vacancy'

        expect(page).to have_content('Job title can\'t be blank')
      end

      scenario 'can be succesfuly edited' do
        vacancy = create(:vacancy, :published, school: school)
        visit edit_school_vacancy_path(school_id: school.id, id: vacancy.id)
        click_link_in_container_with_text('Job title')

        fill_in 'job_specification_form[job_title]', with: 'Assistant Head Teacher'
        click_on 'Update vacancy'

        expect(page).to have_content(I18n.t('messages.vacancies.updated'))
        expect(page).to have_content('Assistant Head Teacher')
      end
    end

    context '#candidate_specification' do
      scenario 'can not be edited when validation fails' do
        vacancy = create(:vacancy, :published, school: school)
        visit edit_school_vacancy_path(school_id: school.id, id: vacancy.id)

        expect(page).to have_content("Edit vacancy for #{school.name}")
        click_link_in_container_with_text(I18n.t('vacancies.experience'))

        fill_in 'candidate_specification_form[experience]', with: ''
        click_on 'Update vacancy'

        within_row_for(text: I18n.t('vacancies.experience')) do
          expect(page).to have_content('can\'t be blank')
        end
      end

      scenario 'can be succesfuly edited' do
        vacancy = create(:vacancy, :published, school: school)
        visit edit_school_vacancy_path(school_id: school.id, id: vacancy.id)
        click_link_in_container_with_text(I18n.t('vacancies.qualifications'))

        fill_in 'candidate_specification_form[qualifications]', with: 'Teaching deegree'
        click_on 'Update vacancy'

        expect(page).to have_content(I18n.t('messages.vacancies.updated'))
        expect(page).to have_content('Teaching deegree')
      end
    end

    context '#application_details' do
      scenario 'can not be edited when validation fails' do
        vacancy = create(:vacancy, :published, school: school)
        visit edit_school_vacancy_path(school_id: school.id, id: vacancy.id)

        expect(page).to have_content("Edit vacancy for #{school.name}")
        click_link_in_container_with_text(I18n.t('vacancies.application_link'))

        fill_in 'application_details_form[application_link]', with: 'some link'
        click_on 'Update vacancy'

        within_row_for(text: I18n.t('vacancies.application_link')) do
          expect(page).to have_content(I18n.t('errors.url.invalid'))
        end
      end

      scenario 'can be succesfuly edited' do
        vacancy = create(:vacancy, :published, school: school)
        visit edit_school_vacancy_path(school_id: school.id, id: vacancy.id)
        click_link_in_container_with_text(I18n.t('vacancies.application_link'))

        fill_in 'application_details_form[application_link]', with: 'https://tvs.com'
        click_on 'Update vacancy'

        expect(page).to have_content(I18n.t('messages.vacancies.updated'))
        expect(page).to have_content('https://tvs.com')
      end
    end
  end
end
