require 'rails_helper'
RSpec.feature 'Copying a vacancy' do
  let(:school) { create(:school) }

  before(:each) do
    stub_hiring_staff_auth(urn: school.urn)
  end

  scenario 'a job can be successfully copied and published' do
    original_vacancy = build(:vacancy, :past_publish, school: school)
    original_vacancy.save(validate: false) # Validation prevents publishing on a past date

    new_vacancy = original_vacancy.dup
    new_vacancy.job_title = 'A new job title'
    new_vacancy.starts_on = 35.days.from_now
    new_vacancy.ends_on = 100.days.from_now
    new_vacancy.publish_on = 0.days.from_now
    new_vacancy.expires_on = 30.days.from_now

    visit school_path

    within('table.vacancies') do
      click_on I18n.t('jobs.copy_link')
    end

    expect(page).to have_content(I18n.t('jobs.copy_page_title', job_title: original_vacancy.job_title))
    within('form.copy-form') do
      fill_in_copy_vacancy_form_fields(new_vacancy)
      click_on I18n.t('buttons.save_and_continue')
    end

    expect(page).to have_content(I18n.t('jobs.review_heading', school: school.name))
    click_on I18n.t('jobs.submit')

    expect(page).to have_content(I18n.t('jobs.confirmation_page.submitted'))
    click_on('Preview your job listing')

    expect(page).to have_content(new_vacancy.job_title)
    expect(page).to have_content(new_vacancy.starts_on)
    expect(page).to have_content(new_vacancy.ends_on)
    expect(page).to have_content(new_vacancy.publish_on)
    expect(page).to have_content(new_vacancy.expires_on)

    expect(page).not_to have_content(original_vacancy.job_title)
    expect(page).not_to have_content(original_vacancy.starts_on)
    expect(page).not_to have_content(original_vacancy.ends_on)
    expect(page).not_to have_content(original_vacancy.publish_on)
    expect(page).not_to have_content(original_vacancy.expires_on)
  end

  context 'when the original job is pending/scheduled/future_publish' do
    scenario 'a job can be successfully copied' do
      original_vacancy = create(:vacancy, :future_publish, school: school)

      visit school_path

      click_on I18n.t('jobs.pending_jobs')
      within('table.vacancies') do
        click_on I18n.t('jobs.copy_link')
      end

      expect(page).to have_content(I18n.t('jobs.copy_page_title', job_title: original_vacancy.job_title))
      within('form.copy-form') do
        click_on I18n.t('buttons.save_and_continue')
      end

      expect(page).to have_content(I18n.t('jobs.review_heading', school: school.name))
    end
  end

  context 'when the original job has expired' do
    scenario 'a job can be successfully copied' do
      original_vacancy = create(:vacancy, :expired, school: school)

      new_vacancy = original_vacancy.dup
      new_vacancy.job_title = 'A new job title'
      new_vacancy.starts_on = 35.days.from_now
      new_vacancy.ends_on = 100.days.from_now
      new_vacancy.publish_on = 0.days.from_now
      new_vacancy.expires_on = 30.days.from_now

      visit school_path

      click_on I18n.t('jobs.expired_jobs')
      within('table.vacancies') do
        click_on I18n.t('jobs.copy_link')
      end

      expect(page).to have_content(I18n.t('jobs.copy_page_title', job_title: original_vacancy.job_title))
      within('form.copy-form') do
        fill_in_copy_vacancy_form_fields(new_vacancy)
        click_on I18n.t('buttons.save_and_continue')
      end

      expect(page).to have_content(I18n.t('jobs.review_heading', school: school.name))
    end
  end

  describe 'validations' do
    let!(:original_vacancy) do
      vacancy = build(:vacancy, :past_publish, school: school)
      vacancy.save(validate: false) # Validation prevents publishing on a past date
      vacancy
    end
    let(:new_vacancy) { build(:vacancy, original_vacancy.attributes.merge(new_attributes)) }

    before do
      visit school_path

      within('table.vacancies') do
        click_on I18n.t('jobs.copy_link')
      end

      expect(page).to have_content(I18n.t('jobs.copy_page_title', job_title: original_vacancy.job_title))
      within('form.copy-form') do
        fill_in_copy_vacancy_form_fields(new_vacancy)
        click_on I18n.t('buttons.save_and_continue')
      end
    end

    context 'when publish on is blank' do
      let(:new_attributes) { { publish_on: nil } }

      it 'shows an error' do
        expect(page).to have_content("Publish on can't be blank")
      end
    end

    context 'when publish on date is in the past' do
      let(:new_attributes) { { publish_on: 1.day.ago } }

      it 'shows an error' do
        expect(page).to have_content("Publish on can't be before today")
      end
    end

    context 'when expires on is blank' do
      let(:new_attributes) { { expires_on: nil } }

      it 'shows an error' do
        expect(page).to have_content("Expires on can't be blank")
      end
    end

    context 'when job title is blank' do
      let(:new_attributes) { { job_title: nil } }

      it 'shows an error' do
        expect(page).to have_content("Job title can't be blank")
      end
    end
  end
end
