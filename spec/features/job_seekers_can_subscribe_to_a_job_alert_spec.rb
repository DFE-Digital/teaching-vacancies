require 'rails_helper'

RSpec.feature 'A job seeker can subscribe to a job alert' do
  before { allow(EmailAlertsFeature).to receive(:enabled?) { true } }

  context 'A job seeker' do
    scenario 'can access the new subscription page when search criteria have been specified' do
      expect { visit(new_subscription_path) }.to raise_error(ActionController::ParameterMissing)

      visit new_subscription_path(search_criteria: { some_parameters: 'none' })
      expect(page).to have_content(I18n.t('subscriptions.new'))
    end

    scenario 'can view the search criteria' do
      visit new_subscription_path(search_criteria: { newly_qualified_teacher: 'true',
                                                     subject: 'physics',
                                                     job_title: 'teacher',
                                                     location: 'EC2 9AN',
                                                     radius: '10',
                                                     working_pattern: 'full_time',
                                                     minimum_salary: '20000',
                                                     maximum_salary: '30000' })

      expect(page).to have_content('Subject: physics')
      expect(page).to have_content('Job title: teacher')
      expect(page).to have_content('Suitable for NQTs')
      expect(page).to have_content('Location: Within 10 miles of EC2 9AN')
      expect(page).to have_content('Working pattern: Full-time')
      expect(page).to have_content('Minimum salary: £20,000')
      expect(page).to have_content('Maximum salary: £30,000')
    end

    scenario 'subscribing to a search creates a new daily subscription audit' do
      visit new_subscription_path(search_criteria: { job_title: 'test' })
      fill_in 'subscription[email]', with: 'jane.doe@example.com'
      click_on 'Subscribe'

      activity = PublicActivity::Activity.last
      expect(activity.key).to eq('subscription.daily_alert.create')
    end

    context 'can create a new subscription' do
      scenario 'when the email address is valid' do
        visit new_subscription_path(search_criteria: { job_title: 'test' })
        fill_in 'subscription[email]', with: 'jane.doe@example.com'
        click_on 'Subscribe'

        expect(page).to have_content(I18n.t('subscriptions.confirmation.header'))
      end

      scenario 'when the email address is associated with other active subscriptions' do
        create(:daily_subscription, email: 'jane.doe@example.com',
                                    search_criteria: { job_title: 'teacher' }.to_json)

        visit new_subscription_path(search_criteria: { job_title: 'math teacher' })
        fill_in 'subscription[email]', with: 'jane.doe@example.com'
        click_on 'Subscribe'

        expect(page).to have_content(I18n.t('subscriptions.confirmation.header'))
      end

      scenario 'when the email address is associated with the same inactive subscriptions' do
        create(:daily_subscription, email: 'jane.doe@example.com',
                                    expires_on: 1.day.ago,
                                    search_criteria: { job_title: 'teacher' }.to_json)

        visit new_subscription_path(search_criteria: { job_title: 'teacher' })
        fill_in 'subscription[email]', with: 'jane.doe@example.com'
        click_on 'Subscribe'

        expect(page).to have_content(I18n.t('subscriptions.confirmation.header'))
      end

      scenario 'when no reference is set' do
        visit new_subscription_path(search_criteria: { job_title: 'test' })
        fill_in 'subscription[email]', with: 'jane.doe@example.com'
        click_on 'Subscribe'

        expect(page).to have_content(I18n.t('subscriptions.confirmation.header'))
      end

      context 'and is redirected to the confirmation page' do
        scenario 'when setting a reference number' do
          visit new_subscription_path(search_criteria: { job_title: 'teacher' })
          fill_in 'subscription[email]', with: 'jane.doe@example.com'
          fill_in 'subscription[reference]', with: 'Daily alert reference'
          click_on 'Subscribe'

          expect(page).to have_content(/Your reference: Daily alert reference/)
        end

        scenario 'where they can go back to the filtered search' do
          visit new_subscription_path(search_criteria: { job_title: 'teacher',
                                                         newly_qualified_teacher: 'true' })
          fill_in 'subscription[email]', with: 'jane.doe@example.com'
          click_on 'Subscribe'

          click_on 'Return to your search results'

          expect(page.find('#job_title').value).to eq('teacher')
          expect(page.find('#newly_qualified_teacher').checked?).to eq(true)
        end
      end
    end

    context 'is not able to create a new subscription' do
      scenario 'when the email address is invalid' do
        visit new_subscription_path(search_criteria: { job_title: 'test' })
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

    scenario 'can successfuly subscribe to a new alert', elasticsearch: true do
      create_list(:vacancy, 5, :published, job_title: 'Math')
      create_list(:vacancy, 3, :published, job_title: 'English')

      Vacancy.__elasticsearch__.client.indices.flush

      visit jobs_path

      within '.filters-form' do
        fill_in 'subject', with: 'English'
        page.find('.govuk-button[type=submit]').click
      end

      expect(page).to have_content('3 jobs match your search')

      click_on 'Sign up for a job alert matching your search'

      expect(page).to have_content(I18n.t('subscriptions.new'))
      expect(page).to have_content('Subject: English')

      fill_in 'subscription[email]', with: 'john.doe@sample-email.com'
      fill_in 'subscription[reference]', with: 'Daily alerts for: English'

      message_delivery = instance_double(ActionMailer::MessageDelivery)
      expect(SubscriptionMailer).to receive(:confirmation) { message_delivery }
      expect(message_delivery).to receive(:deliver_later)
      click_on 'Subscribe'

      expect(page).to have_content(I18n.t('subscriptions.confirmation.header'))
      click_on 'Return to your search results'

      expect(page).to have_content('3 jobs match your search')

      activities = PublicActivity::Activity.all
      keys = activities.pluck(:key)
      expect(keys).to include('subscription.daily_alert.new')
      expect(keys).to include('subscription.daily_alert.create')
    end
  end
end
