require 'rails_helper'

RSpec.feature 'A job seeker can subscribe to a job alert' do
  before { allow(EmailAlertsFeature).to receive(:enabled?) { true } }

  context 'A job seeker' do
    scenario 'can access the new subscription page when search criteria have been specified' do
      expect { visit(new_subscription_path) }.to raise_error(ActionController::ParameterMissing)

      visit new_subscription_path(search_criteria: { some_parameters: 'none' })
      expect(page).to have_content(I18n.t('subscriptions.new.page_description'))
    end

    context 'when carrying out a location category search' do
      scenario 'can view the search criteria' do
        visit new_subscription_path(
          search_criteria: { keyword: 'physics', location: 'London', location_category: 'London' }
        )

        expect(page).to have_content('Keyword: physics')
        expect(page).to have_content('Location: In London')
      end
    end

    context 'when carrying out a geographical radius location search' do
      scenario 'can view the search criteria' do
        visit new_subscription_path(search_criteria: { keyword: 'physics', location: 'EC2 9AN', radius: '10' })

        expect(page).to have_content('Keyword: physics')
        expect(page).to have_content('Location: Within 10 miles of EC2 9AN')
      end
    end

    scenario 'subscribing to a search creates a new daily subscription audit' do
      visit new_subscription_path(search_criteria: { keyword: 'test' })
      fill_in 'subscription[email]', with: 'jane.doe@example.com'
      click_on 'Subscribe'

      activity = PublicActivity::Activity.last
      expect(activity.key).to eq('subscription.daily_alert.create')
    end

    context 'can create a new subscription' do
      scenario 'when the email address is valid' do
        visit new_subscription_path(search_criteria: { keyword: 'test' })
        fill_in 'subscription[email]', with: 'jane.doe@example.com'
        click_on 'Subscribe'

        expect(page).to have_content(I18n.t('subscriptions.confirmation.header'))
      end

      scenario 'when the email address is associated with other active subscriptions' do
        create(:daily_subscription, email: 'jane.doe@example.com',
                                    search_criteria: { keyword: 'teacher' }.to_json)

        visit new_subscription_path(search_criteria: { keyword: 'math teacher' })
        fill_in 'subscription[email]', with: 'jane.doe@example.com'
        click_on 'Subscribe'

        expect(page).to have_content(I18n.t('subscriptions.confirmation.header'))
      end

      scenario 'when no reference is set' do
        visit new_subscription_path(search_criteria: { keyword: 'test' })
        fill_in 'subscription[email]', with: 'jane.doe@example.com'
        click_on 'Subscribe'

        expect(page).to have_content(I18n.t('subscriptions.confirmation.header'))
      end

      context 'and is redirected to the confirmation page' do
        scenario 'when setting a reference number' do
          visit new_subscription_path(search_criteria: { keyword: 'teacher' })
          fill_in 'subscription[email]', with: 'jane.doe@example.com'
          fill_in 'subscription[reference]', with: 'Daily alert reference'
          click_on 'Subscribe'

          expect(page).to have_content(/Daily alert reference/)
        end

        scenario 'where they can go back to the filtered search' do
          visit new_subscription_path(search_criteria: { keyword: 'teacher' })
          fill_in 'subscription[email]', with: 'jane.doe@example.com'
          click_on 'Subscribe'

          click_on 'Return to your search results'

          expect(page.find_field('jobs_search_form[keyword]').value).to eq('teacher')
        end
      end
    end

    context 'is not able to create a new subscription' do
      scenario 'when the email address is invalid' do
        visit new_subscription_path(search_criteria: { keyword: 'test' })
        fill_in 'subscription[email]', with: 'jane.doe@example'
        click_on 'Subscribe'

        expect(page).to have_content('There is a problem')
        expect(page).to have_content('Enter an email address in the correct format, like name@example.com')
      end

      scenario 'when an active subscription with the same search_criteria exists' do
        search_criteria = { location: 'EC2 9AN', radius: '10' }

        create(:daily_subscription, email: 'jane.doe@example.com',
                                    search_criteria: search_criteria.to_json)

        visit new_subscription_path(search_criteria: search_criteria)
        fill_in 'subscription[email]', with: 'jane.doe@example.com'
        click_on 'Subscribe'

        expect(page).to have_content("You're already subscribed to an alert for these search criteria")
      end
    end

    scenario 'can successfuly subscribe to a new alert' do
      visit jobs_path

      within '.filters-form' do
        fill_in 'jobs_search_form[keyword]', with: 'English'
        fill_in 'jobs_search_form[location]', with: 'London'
        check I18n.t('jobs.job_role_options.teacher'), name: 'jobs_search_form[job_roles][]', visible: false
        check I18n.t('jobs.job_role_options.nqt_suitable'), name: 'jobs_search_form[job_roles][]', visible: false
        check I18n.t('jobs.school_phase_options.secondary'), name: 'jobs_search_form[phases][]', visible: false
        check I18n.t('jobs.working_pattern_options.full_time'),
              name: 'jobs_search_form[working_patterns][]', visible: false
        click_on I18n.t('buttons.search')
      end

      click_on I18n.t('subscriptions.link.text')

      expect(page).to have_content(I18n.t('subscriptions.new.page_description'))
      expect(page).to have_content('Keyword: English')
      expect(page).to have_content('Location: In London')
      expect(page).to have_content('Job roles: Teacher, Suitable for NQTs')
      expect(page).to have_content('Education phases: Secondary')
      expect(page).to have_content('Working patterns: Full-time')

      fill_in 'subscription[email]', with: 'john.doe@sample-email.com'
      fill_in 'subscription[reference]', with: 'Daily alerts for: English'

      message_delivery = instance_double(ActionMailer::MessageDelivery)
      expect(SubscriptionMailer).to receive(:confirmation) { message_delivery }
      expect(message_delivery).to receive(:deliver_later)
      click_on 'Subscribe'

      expect(page).to have_content(I18n.t('subscriptions.confirmation.header'))
      click_on 'Return to your search results'

      expect(page.current_path).to eql(jobs_path)

      activities = PublicActivity::Activity.all
      keys = activities.pluck(:key)
      expect(keys).to include('subscription.daily_alert.new')
      expect(keys).to include('subscription.daily_alert.create')
    end
  end
end
