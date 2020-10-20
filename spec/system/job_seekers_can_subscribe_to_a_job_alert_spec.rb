require 'rails_helper'

RSpec.describe 'A job seeker can subscribe to a job alert' do
  context 'A job seeker' do
    scenario 'can access the new subscription page when search criteria have been specified' do
      expect { visit(new_subscription_path) }.to raise_error(ActionController::ParameterMissing)

      visit new_subscription_path(search_criteria: { some_parameters: 'none' })
      expect(page).to have_content(I18n.t('subscriptions.new.title'))
    end

    context 'when carrying out a location category search' do
      scenario 'can view the search criteria' do
        visit new_subscription_path(
          search_criteria: { keyword: 'physics', location: 'London', location_category: 'London' },
        )

        expect(page.find_field('subscription-form-keyword-field').value).to eql('physics')
        expect(page.find_field('subscription-form-location-field').value).to eql('London')
      end
    end

    context 'when carrying out a geographical radius location search' do
      scenario 'can view the search criteria' do
        visit new_subscription_path(search_criteria: { keyword: 'physics', location: 'EC2 9AN', radius: '10' })

        expect(page.find_field('subscription-form-keyword-field').value).to eql('physics')
        expect(page.find_field('subscription-form-location-field').value).to eql('EC2 9AN')
        expect(page.find_field('subscription-form-radius-field').value).to eql('10')
      end
    end

    scenario 'subscribing to a search creates a new daily subscription audit' do
      visit new_subscription_path(search_criteria: { keyword: 'test' })
      fill_in 'subscription_form[email]', with: 'jane.doe@example.com'
      page.choose('Daily')
      click_on 'Subscribe'

      activity = PublicActivity::Activity.last
      expect(activity.key).to eq('subscription.daily_alert.create')
    end

    context 'can create a new subscription' do
      scenario 'when the email address is valid' do
        visit new_subscription_path(search_criteria: { keyword: 'test' })
        fill_in 'subscription_form[email]', with: 'jane.doe@example.com'
        page.choose('Daily')
        click_on 'Subscribe'

        expect(page).to have_content(I18n.t('subscriptions.confirm.header'))
      end

      scenario 'when the email address is associated with other active subscriptions' do
        create(:daily_subscription, email: 'jane.doe@example.com',
                                    search_criteria: { keyword: 'teacher' }.to_json)

        visit new_subscription_path(search_criteria: { keyword: 'math teacher' })
        fill_in 'subscription_form[email]', with: 'jane.doe@example.com'
        page.choose('Daily')
        click_on 'Subscribe'

        expect(page).to have_content(I18n.t('subscriptions.confirm.header'))
      end

      context 'when alert frequency is daily' do
        scenario 'redirects to the confirmation page' do
          visit new_subscription_path(search_criteria: { keyword: 'teacher' })
          page.choose('Daily')
          click_on 'Subscribe'

          expect(page).to have_content(I18n.t('subscriptions.frequency.daily'))
        end
      end

      context 'when alert frequency is weekly' do
        scenario 'redirects to the confirmation page' do
          visit new_subscription_path(search_criteria: { keyword: 'teacher' })
          page.choose('Weekly')
          click_on 'Subscribe'

          expect(page).to have_content(I18n.t('subscriptions.frequency.weekly'))
        end
      end

      context 'and is redirected to the confirmation page' do
        scenario 'where they can go back to the filtered search' do
          visit new_subscription_path(search_criteria: { keyword: 'teacher' })
          fill_in 'subscription_form[email]', with: 'jane.doe@example.com'
          page.choose('Daily')
          click_on 'Subscribe'

          click_on 'Return to your search results'

          expect(page.find_field('jobs_search_form[keyword]').value).to eq('teacher')
        end
      end
    end

    context 'is not able to create a new subscription' do
      scenario 'when the email address is invalid' do
        visit new_subscription_path(search_criteria: { keyword: 'test' })
        fill_in 'subscription_form[email]', with: 'jane.doe@example'
        click_on 'Subscribe'

        expect(page).to have_content('There is a problem')
        expect(page).to have_content('Enter an email address in the correct format, like name@example.com')
      end

      scenario 'when an active subscription with the same search_criteria exists' do
        search_criteria = { location: 'EC2 9AN', radius: '10' }

        create(:daily_subscription, email: 'jane.doe@example.com', frequency: 'daily',
                                    search_criteria: search_criteria.to_json)

        visit new_subscription_path(search_criteria: search_criteria)
        fill_in 'subscription_form[email]', with: 'jane.doe@example.com'
        page.choose('Daily')
        click_on 'Subscribe'

        expect(page).to have_content('A job alert matching this criteria already exists')
      end
    end

    context 'when a location category search is carried out' do
      before do
        LocationPolygon.create(name: 'london')
      end

      scenario 'can successfuly subscribe to a new alert' do
        visit jobs_path

        within '.filters-form' do
          fill_in 'jobs_search_form[keyword]', with: 'English'
          fill_in 'jobs_search_form[location]', with: 'London'
          check I18n.t('jobs.job_role_options.teacher'), name: 'jobs_search_form[job_roles][]', visible: false
          check I18n.t('jobs.job_role_options.nqt_suitable'), name: 'jobs_search_form[job_roles][]', visible: false
          check I18n.t('jobs.working_pattern_options.full_time'),
                name: 'jobs_search_form[working_patterns][]', visible: false
          click_on I18n.t('buttons.search')
        end

        if page.has_css?('#job-alert-link')
          click_on('Receive a job alert')
        else
          click_on('get notified')
        end

        expect(page).to have_content(I18n.t('subscriptions.new.title'))
        expect(page.find_field('subscription-form-keyword-field').value).to eql('English')
        expect(page.find_field('subscription-form-location-field').value).to eql('London')
        expect(page.find_field('subscription-form-job-roles-teacher-field').checked?).to be true
        expect(page.find_field('subscription-form-job-roles-nqt-suitable-field').checked?).to be true
        expect(page.find_field('subscription-form-working-patterns-full-time-field').checked?).to be true

        fill_in 'subscription_form[email]', with: 'john.doe@sample-email.com'
        page.choose('Daily')

        message_delivery = instance_double(ActionMailer::MessageDelivery)
        expect(SubscriptionMailer).to receive(:confirmation) { message_delivery }
        expect(message_delivery).to receive(:deliver_later)
        click_on 'Subscribe'

        expect(page).to have_content(I18n.t('subscriptions.confirm.header'))
        click_on 'Return to your search results'

        expect(page.current_path).to eql(jobs_path)

        activities = PublicActivity::Activity.all
        keys = activities.pluck(:key)
        expect(keys).to include('subscription.alert.new')
        expect(keys).to include('subscription.daily_alert.create')
      end
    end

    context 'when a location search is carried out' do
      scenario 'can successfuly subscribe to a new alert' do
        visit jobs_path

        within '.filters-form' do
          fill_in 'jobs_search_form[keyword]', with: 'English'
          fill_in 'jobs_search_form[location]', with: 'SW1A 1AA'
          select '40 miles', from: 'jobs_search_form[radius]'
          check I18n.t('jobs.job_role_options.teacher'), name: 'jobs_search_form[job_roles][]', visible: false
          check I18n.t('jobs.job_role_options.nqt_suitable'), name: 'jobs_search_form[job_roles][]', visible: false
          check I18n.t('jobs.working_pattern_options.full_time'),
                name: 'jobs_search_form[working_patterns][]', visible: false
          click_on I18n.t('buttons.search')
        end

        if page.has_css?('#job-alert-link')
          click_on('Receive a job alert')
        else
          click_on('get notified')
        end

        expect(page).to have_content(I18n.t('subscriptions.new.title'))
        expect(page.find_field('subscription-form-keyword-field').value).to eql('English')
        expect(page.find_field('subscription-form-location-field').value).to eql('SW1A 1AA')
        expect(page.find_field('subscription-form-radius-field').value).to eql('40')
        expect(page.find_field('subscription-form-job-roles-teacher-field').checked?).to be true
        expect(page.find_field('subscription-form-job-roles-nqt-suitable-field').checked?).to be true
        expect(page.find_field('subscription-form-working-patterns-full-time-field').checked?).to be true

        fill_in 'subscription_form[email]', with: 'john.doe@sample-email.com'
        page.choose('Daily')

        message_delivery = instance_double(ActionMailer::MessageDelivery)
        expect(SubscriptionMailer).to receive(:confirmation) { message_delivery }
        expect(message_delivery).to receive(:deliver_later)
        click_on 'Subscribe'

        expect(page).to have_content(I18n.t('subscriptions.confirm.header'))
        click_on 'Return to your search results'

        expect(page.current_path).to eql(jobs_path)

        activities = PublicActivity::Activity.all
        keys = activities.pluck(:key)
        expect(keys).to include('subscription.alert.new')
        expect(keys).to include('subscription.daily_alert.create')
      end
    end
  end
end
