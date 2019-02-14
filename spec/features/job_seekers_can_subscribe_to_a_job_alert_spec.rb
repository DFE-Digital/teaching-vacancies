require 'rails_helper'

RSpec.feature 'A job seeker can subscribe to a job alert' do
  context 'A job seeker' do
    scenario 'can access the new subscription page when search criteria have been specified' do
      expect { visit(new_subscription_path) }.to raise_error(ActionController::ParameterMissing)

      visit new_subscription_path(search_criteria: { some_parameters: 'none' })
      expect(page).to have_content('Sign up for daily emails')
    end

    scenario 'can view the search criteria' do
      visit new_subscription_path(search_criteria: { newly_qualified_teacher: 'true',
                                                     keyword: 'teacher',
                                                     location: 'EC2 9AN',
                                                     radius: '10',
                                                     working_pattern: 'full_time',
                                                     minimum_salary: '20000',
                                                     maximum_salary: '30000' })

      expect(page).to have_content('Keyword: teacher')
      expect(page).to have_content('Suitable for NQTs')
      expect(page).to have_content('Location: Within 10 miles of EC2 9AN')
      expect(page).to have_content('Working pattern: Full time')
      expect(page).to have_content('Minimum salary: £20,000')
      expect(page).to have_content('Maximum salary: £30,000')
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

      scenario 'when the email address is associated with the same inactive subscriptions' do
        create(:daily_subscription, email: 'jane.doe@example.com',
                                    expires_on: 1.day.ago,
                                    search_criteria: { keyword: 'teacher' }.to_json)

        visit new_subscription_path(search_criteria: { keyword: 'teacher' })
        fill_in 'subscription[email]', with: 'jane.doe@example.com'
        click_on 'Subscribe'

        expect(page).to have_content(I18n.t('subscriptions.confirmation.header'))
      end

      context 'and is redirected to the confirmation page' do
        scenario 'without setting a reference number' do
          visit new_subscription_path(search_criteria: { keyword: 'teacher' })
          fill_in 'subscription[email]', with: 'jane.doe@example.com'
          click_on 'Subscribe'

          expect(page).to have_content(I18n.t('subscriptions.confirmation.header'))
          expect(page).to have_content('jane.doe@example.com')
          expect(page).to have_content(/Your reference [a-z]*/)
          expect(page).to have_content('Keyword: teacher')
        end

        scenario 'when setting a reference number' do
          visit new_subscription_path(search_criteria: { keyword: 'teacher' })
          fill_in 'subscription[email]', with: 'jane.doe@example.com'
          fill_in 'subscription[reference]', with: 'Daily alert reference'
          click_on 'Subscribe'

          expect(page).to have_content(/Your reference Daily alert reference/)
        end

        scenario 'where they can go back to the filtered search' do
          visit new_subscription_path(search_criteria: { keyword: 'teacher',
                                                         newly_qualified_teacher: 'true' })
          fill_in 'subscription[email]', with: 'jane.doe@example.com'
          click_on 'Subscribe'

          click_on 'Return to your search results'

          expect(page.find('#keyword').value).to eq('teacher')
          expect(page.find('#newly_qualified_teacher').checked?).to eq(true)
        end
      end
    end

    context 'is not able to create a new subscription' do
      scenario 'when the email address is invalid' do
        visit new_subscription_path(search_criteria: { keyword: 'test' })
        fill_in 'subscription[email]', with: 'jane.doe@example'
        click_on 'Subscribe'

        expect(page).to have_content('Please correct the following error')
        expect(page).to have_content('Email is not a valid email address')
      end

      scenario 'when an active subcsription with the same search_criteria exists' do
        search_criteria = { location: 'EC2 9AN', radius: '10' }

        create(:daily_subscription, email: 'jane.doe@example.com',
                                    search_criteria: search_criteria.to_json)

        visit new_subscription_path(search_criteria: search_criteria)
        fill_in 'subscription[email]', with: 'jane.doe@example.com'
        click_on 'Subscribe'

        expect(page).to have_content('You are already subscribed to a daily email with these search criteria')
      end
    end

    scenario 'can succesfuly subscribe to a new alert', elasticsearch: true do
      create_list(:vacancy, 5, :published, job_title: 'Math')
      create_list(:vacancy, 3, :published, job_title: 'English')

      Vacancy.__elasticsearch__.client.indices.flush

      visit jobs_path

      within '.filters-form' do
        fill_in 'keyword', with: 'English'
        page.find('.govuk-button[type=submit]').click
      end

      expect(page).to have_content('3 jobs match your search')

      click_on 'Subscribe to email notifications for this search'

      expect(page).to have_content('Sign up for daily emails')
      expect(page).to have_content('Keyword: English')

      fill_in 'subscription[email]', with: 'john.doe@sample-email.com'
      fill_in 'subscription[reference]', with: 'Daily alerts for: English'

      Sidekiq::Testing.inline! do
        expect(SubscriptionConfirmationEmail).to receive_message_chain(:new, :call)
        click_on 'Subscribe'
      end

      expect(page).to have_content('Your email subscription has started')
      click_on 'Return to your search results'

      expect(page).to have_content('3 jobs match your search')

      activities = PublicActivity::Activity.all
      expect(activities[0].key).to eq('subscription.daily_alert.new')
      expect(activities[1].key).to eq('subscription.daily_alert.create')
      expect(activities[2].key).to eq('subscription.daily_alert.confirmation.sent')
    end
  end
end
