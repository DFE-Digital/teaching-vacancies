require 'rails_helper'

RSpec.feature 'A job seeker can subscribe to a job alert', wip: true do
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

        expect(page).to have_content('Email subscription created successfully')
      end

      scenario 'when the email address is associated with other active subscriptions' do
        create(:daily_subscription, email: 'jane.doe@example.com',
                                    search_criteria: { keyword: 'teacher' }.to_json)

        visit new_subscription_path(search_criteria: { keyword: 'math teacher' })
        fill_in 'subscription[email]', with: 'jane.doe@example.com'
        click_on 'Subscribe'

        expect(page).to have_content('Email subscription created successfully')
      end

      scenario 'when the email address is associated with the same inactive subscriptions' do
        create(:daily_subscription, email: 'jane.doe@example.com',
                                    expires_on: 1.day.ago,
                                    search_criteria: { keyword: 'teacher' }.to_json)

        visit new_subscription_path(search_criteria: { keyword: 'teacher' })
        fill_in 'subscription[email]', with: 'jane.doe@example.com'
        click_on 'Subscribe'

        expect(page).to have_content('Email subscription created successfully')
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
  end
end
