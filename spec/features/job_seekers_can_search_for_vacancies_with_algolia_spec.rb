require 'rails_helper'

RSpec.feature 'Algolia search with javascript disabled', js: false, algolia: true do
  before(:each) do
    skip_vacancy_publish_on_validation

    @first_school = create(:school, town: 'Bradford')
    @second_school = create(:school, town: 'Abingdon', geolocation: Geocoder::DEFAULT_STUB_COORDINATES)

    @draft_vacancy = create(:vacancy, :draft, job_title: 'English Teacher', subjects: ['English'])
    @expired_vacancy = create(:vacancy, :expired, job_title: 'Drama Teacher', subjects: ['Drama'])

    @first_vacancy = create(
      :vacancy, :published, job_title: 'Head of Science', subjects: ['Science'], school: @first_school,
      publish_on: 1.day.ago, expires_on: 5.days.from_now, expiry_time: Time.zone.now + 5.days + 2.hours
    )

    @second_vacancy = create(
      :vacancy, :published, job_title: 'Science Teacher', subjects: ['Science'], school: @second_school,
      publish_on: 2.days.ago, expires_on: 5.days.from_now, expiry_time: Time.zone.now + 5.days + 1.hour
    )

    @third_vacancy = create(
      :vacancy, :published, job_title: 'Maths Teacher', subjects: ['Maths'], school: @second_school,
      publish_on: 4.days.ago, expires_on: 2.days.from_now, expiry_time: Time.zone.now + 2.days + 4.hours
    )

    @fourth_vacancy = create(
      :vacancy, :published, job_title: 'Primary Teacher', subjects: ['All or not applicable'], school: @first_school,
      publish_on: 5.days.ago, expires_on: 10.days.from_now, expiry_time: Time.zone.now + 10.days + 2.hours
    )

    @fifth_vacancy = create(
      :vacancy, :published, job_title: 'Teacher of History', subjects: ['History'],
      publish_on: 9.days.ago, expires_on: 2.days.from_now, expiry_time: Time.zone.now + 2.days + 5.hours
    )

    WebMock.disable!
    Vacancy.reindex!
  end

  after(:each) do
    WebMock.disable!
    Vacancy.clear_index!
  end

  context 'jobseekers can search for vacancies' do
    context 'from a location category landing page' do
      scenario 'only matching published vacancies are listed' do
        visit location_category_path('bradford')

        expect(page).to have_content(
          I18n.t('jobs.job_count_plural_with_location_category', count: 2, location: 'Bradford')
        )
        expect(page).to have_selector('.vacancy', count: 2)
      end

      scenario 'radius filter is disabled' do
        visit location_category_path('bradford')

        expect(page).to have_field('radius', disabled: true)
      end

      scenario 'radius filter is re-enabled when the location field is clicked' do
        visit location_category_path('bradford')

        expect(page).to have_field('radius', disabled: true)
        page.find('#location').click

        expect(page).to have_field('radius', disabled: false)
      end
    end

    context 'from the home page' do
      context 'with no search criteria' do
        scenario 'only published vacancies are listed' do
          visit page_path(:home)

          within '.search_panel' do
            click_on I18n.t('buttons.search')
          end

          expect(page).to have_content(
            I18n.t('jobs.job_count_plural_without_search', count: 5)
          )
          expect(page).to have_selector('.vacancy', count: 5)

          expect(page).not_to have_content(@draft_vacancy.job_title)
          expect(page).not_to have_content(@expired_vacancy.job_title)

          expect(page).to have_content(@first_vacancy.job_title)
          expect(page).to have_content(@second_vacancy.job_title)
          expect(page).to have_content(@third_vacancy.job_title)
          expect(page).to have_content(@fourth_vacancy.job_title)
          expect(page).to have_content(@fifth_vacancy.job_title)
        end
      end

      context 'with keyword and location specified' do
        scenario 'only matching published vacancies are listed' do
          visit page_path(:home)

          within '.search_panel' do
            fill_in 'keyword', with: 'science'
            fill_in 'location', with: 'SW1A 1AA'

            click_on I18n.t('buttons.search')
          end

          expect(page).to have_content(
            I18n.t('jobs.job_count', count: 1)
          )
          expect(page).to have_selector('.vacancy', count: 1)
          expect(page).to have_content(@second_vacancy.job_title)
        end
      end
    end

    context 'from the jobs page' do
      context 'with no search criteria' do
        scenario 'only published vacancies are listed' do
          visit jobs_path

          expect(page).to have_content(
            I18n.t('jobs.job_count_plural_without_search', count: 5)
          )
          expect(page).to have_selector('.vacancy', count: 5)
        end
      end

      context 'with keyword specified' do
        scenario 'only matching published vacancies are listed' do
          visit jobs_path

          within '.filter-vacancies' do
            fill_in 'keyword', with: 'science'

            click_on I18n.t('buttons.search')
          end

          expect(page).to have_content(
            I18n.t('jobs.job_count_plural', count: 2)
          )
          expect(page).to have_selector('.vacancy', count: 2)
          expect(page).to have_content(@first_vacancy.job_title)
          expect(page).to have_content(@second_vacancy.job_title)
        end
      end

      context 'with a location category specified' do
        scenario 'only matching published vacancies are listed' do
          visit jobs_path

          within '.filter-vacancies' do
            fill_in 'location', with: 'Bradford'

            click_on I18n.t('buttons.search')
          end

          expect(page).to have_content(
            I18n.t('jobs.job_count_plural_with_location_category', count: 2, location: 'Bradford')
          )
          expect(page).to have_selector('.vacancy', count: 2)
          expect(page).to have_content(@first_vacancy.job_title)
          expect(page).to have_content(@fourth_vacancy.job_title)
        end
      end

      context 'with a location specified' do
        scenario 'only matching published vacancies are listed' do
          visit jobs_path

          within '.filter-vacancies' do
            fill_in 'location', with: 'SW1A 1AA'

            click_on I18n.t('buttons.search')
          end

          expect(page).to have_content(
            I18n.t('jobs.job_count_plural', count: 2)
          )
          expect(page).to have_selector('.vacancy', count: 2)
          expect(page).to have_content(@second_vacancy.job_title)
          expect(page).to have_content(@third_vacancy.job_title)
        end
      end

      context 'with keyword and location and radius specified' do
        scenario 'only matching published vacancies are listed' do
          visit jobs_path

          within '.filter-vacancies' do
            fill_in 'keyword', with: 'maths'
            fill_in 'location', with: 'SW1A 1AA'
            select '1 mile'

            click_on I18n.t('buttons.search')
          end

          expect(page).to have_content(
            I18n.t('jobs.job_count', count: 1)
          )
          expect(page).to have_selector('.vacancy', count: 1)
          expect(page).not_to have_content(@second_vacancy.job_title)
          expect(page).to have_content(@third_vacancy.job_title)
        end
      end
    end
  end

  context 'jobseekers can sort vacancies' do
    scenario 'newest listing first' do
      visit jobs_path

      within '.sortable-links' do
        select I18n.t('jobs.sort_by.publish_on.descending')
        click_on I18n.t('jobs.sort_by.submit')
      end

      expect(page.find('.vacancy:nth-child(1)')).to have_content(@first_vacancy.job_title)
      expect(page.find('.vacancy:nth-child(2)')).to have_content(@second_vacancy.job_title)
      expect(page.find('.vacancy:nth-child(3)')).to have_content(@third_vacancy.job_title)
      expect(page.find('.vacancy:nth-child(4)')).to have_content(@fourth_vacancy.job_title)
      expect(page.find('.vacancy:nth-child(5)')).to have_content(@fifth_vacancy.job_title)
    end

    scenario 'oldest listing first' do
      visit jobs_path

      within '.sortable-links' do
        select I18n.t('jobs.sort_by.publish_on.ascending')
        click_on I18n.t('jobs.sort_by.submit')
      end

      expect(page.find('.vacancy:nth-child(1)')).to have_content(@fifth_vacancy.job_title)
      expect(page.find('.vacancy:nth-child(2)')).to have_content(@fourth_vacancy.job_title)
      expect(page.find('.vacancy:nth-child(3)')).to have_content(@third_vacancy.job_title)
      expect(page.find('.vacancy:nth-child(4)')).to have_content(@second_vacancy.job_title)
      expect(page.find('.vacancy:nth-child(5)')).to have_content(@first_vacancy.job_title)
    end

    scenario 'least time to apply listing first' do
      visit jobs_path

      within '.sortable-links' do
        select I18n.t('jobs.sort_by.expiry_time.ascending')
        click_on I18n.t('jobs.sort_by.submit')
      end

      expect(page.find('.vacancy:nth-child(1)')).to have_content(@third_vacancy.job_title)
      expect(page.find('.vacancy:nth-child(2)')).to have_content(@fifth_vacancy.job_title)
      expect(page.find('.vacancy:nth-child(3)')).to have_content(@second_vacancy.job_title)
      expect(page.find('.vacancy:nth-child(4)')).to have_content(@first_vacancy.job_title)
      expect(page.find('.vacancy:nth-child(5)')).to have_content(@fourth_vacancy.job_title)
    end

    scenario 'most time to apply listing first' do
      visit jobs_path

      within '.sortable-links' do
        select I18n.t('jobs.sort_by.expiry_time.descending')
        click_on I18n.t('jobs.sort_by.submit')
      end

      expect(page.find('.vacancy:nth-child(1)')).to have_content(@fourth_vacancy.job_title)
      expect(page.find('.vacancy:nth-child(2)')).to have_content(@first_vacancy.job_title)
      expect(page.find('.vacancy:nth-child(3)')).to have_content(@second_vacancy.job_title)
      expect(page.find('.vacancy:nth-child(4)')).to have_content(@fifth_vacancy.job_title)
      expect(page.find('.vacancy:nth-child(5)')).to have_content(@third_vacancy.job_title)
    end
  end

  context 'jobseekers can navigate between pages' do
    let(:jobs_per_page) { 5 }

    before do
      allow_any_instance_of(VacancyAlgoliaSearchBuilder).to receive(:hits_per_page).and_return(jobs_per_page)
    end

    context 'when fewer vacancies than the jobs per page' do
      scenario 'there is only one page' do
        visit jobs_path

        expect(page).to have_selector('.vacancy', count: 5)

        expect(page).not_to have_link('2')
      end
    end

    context 'when more vacancies than the jobs per page' do
      let(:jobs_per_page) { 2 }

      scenario 'there are two pages' do
        visit jobs_path

        expect(page).to have_selector('.vacancy', count: 2)

        within '.pagination' do
          expect(page).to have_link('2')
          click_on '2'
        end

        expect(page).to have_selector('.vacancy', count: 2)

        within '.pagination' do
          expect(page).to have_link('3')
          click_on '3'
        end

        expect(page).to have_selector('.vacancy', count: 1)
      end
    end
  end

  context 'with EmailAlertsFeature ON and ReadOnlyFeature OFF' do
    before { allow(EmailAlertsFeature).to receive(:enabled?) { true } }
    before { allow(ReadOnlyFeature).to receive(:enabled?) { false } }

    scenario 'jobseekers can subscribe to a job alert' do
      visit jobs_path

      within '.filter-vacancies' do
        fill_in 'keyword', with: 'maths'
        fill_in 'location', with: 'SW1A 1AA'
        select '1 mile'

        click_on I18n.t('buttons.search')
      end

      expect(page).to have_content(I18n.t('subscriptions.link.text'))

      click_on I18n.t('subscriptions.link.text')

      expect(page.current_path).to eql(new_subscription_path)
    end
  end
end
