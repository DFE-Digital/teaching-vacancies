require "rails_helper"

RSpec.describe "Jobseekers can create a job alert from a search", recaptcha: true do
  let(:location) { "London" }
  let!(:location_polygon) { create(:location_polygon, name: "london") }

  let(:search_with_polygons?) { false }
  let(:jobseeker_signed_in?) { false }
  let(:jobseeker) { build_stubbed(:jobseeker) }

  describe "recaptcha" do
    context "when verify_recaptcha is false" do
      before do
        allow_any_instance_of(ApplicationController).to receive(:verify_recaptcha).and_return(false)
      end

      scenario "redirects to invalid_recaptcha path" do
        visit new_subscription_path(search_criteria: { keyword: "test", location: "London" })
        fill_in_subscription_fields
        click_on I18n.t("buttons.subscribe")
        expect(page).to have_current_path(invalid_recaptcha_path(form_name: "Subscription"))
      end
    end
  end

  describe "job alert confirmation page" do
    before do
      login_as(jobseeker, scope: :jobseeker) if jobseeker_signed_in?
      visit jobs_path
      and_perform_a_search
      and_click_job_alert_link
      fill_in_subscription_fields
      click_on I18n.t("buttons.subscribe")
    end

    context "when jobseeker has an account" do
      let!(:jobseeker) { create(:jobseeker) }

      context "when jobseeker is signed in" do
        let(:jobseeker_signed_in?) { true }

        scenario "redirects to job alerts dashboard" do
          expect(current_path).to eq(jobseekers_subscriptions_path)
        end
      end

      context "when jobseeker is signed out" do
        scenario "renders a sign in prompt form that redirects to job alerts dashboard" do
          within "div[data-account-prompt='sign-in']" do
            expect(page).to have_content(I18n.t("subscriptions.jobseeker_account_prompt.heading.sign_in"))
            fill_in "Password", with: jobseeker.password
            within(".edit_jobseeker") do
              click_on I18n.t("buttons.sign_in")
            end
          end
          expect(current_path).to eq(jobseekers_subscriptions_path)
        end

        scenario "renders a sign in prompt form that redirects to sign in page on error then redirects to job alerts dashboard" do
          within "div[data-account-prompt='sign-in']" do
            expect(page).to have_content(I18n.t("subscriptions.jobseeker_account_prompt.heading.sign_in"))
            within(".edit_jobseeker") do
              click_on I18n.t("buttons.sign_in")
            end
          end
          sign_in_jobseeker
          expect(current_path).to eq(jobseekers_subscriptions_path)
        end
      end
    end

    context "when jobseeker does not have an account" do
      scenario "renders a create an account prompt form that redirects to job alerts dashboard" do
        within "div[data-account-prompt='sign-up']" do
          expect(page).to have_content(I18n.t("subscriptions.jobseeker_account_prompt.heading.sign_up"))
          fill_in "Password", with: jobseeker.password
          click_on I18n.t("buttons.create_account")
        end
        confirm_email_address
        expect(current_path).to eq(jobseekers_subscriptions_path)
      end

      scenario "renders a create an account prompt form that redirects to sign up page on error then redirects to job alerts dashboard" do
        within "div[data-account-prompt='sign-up']" do
          expect(page).to have_content(I18n.t("subscriptions.jobseeker_account_prompt.heading.sign_up"))
          click_on I18n.t("buttons.create_account")
        end
        sign_up_jobseeker
        confirm_email_address
        expect(current_path).to eq(jobseekers_subscriptions_path)
      end
    end
  end

  describe "location search" do
    before do
      visit jobs_path
      and_perform_a_search
      and_click_job_alert_link
    end

    context "when a polygon search is carried out" do
      let(:search_with_polygons?) { true }
      let(:location) { "London" }

      scenario "successfully creates a job alert" do
        expect(page).to have_content(I18n.t("subscriptions.new.title"))
        and_the_search_criteria_are_populated

        click_on I18n.t("buttons.subscribe")
        expect(page).to have_content("There is a problem")

        fill_in_subscription_fields

        message_delivery = instance_double(ActionMailer::MessageDelivery)
        expect(Jobseekers::SubscriptionMailer).to receive(:confirmation) { message_delivery }
        expect(message_delivery).to receive(:deliver_later)
        click_on I18n.t("buttons.subscribe")
      end
    end

    context "when a point location search is carried out" do
      let(:search_with_polygons?) { false }
      let(:location) { "SW1A 1AA" }

      scenario "successfully creates a job alert" do
        expect(page).to have_content(I18n.t("subscriptions.new.title"))
        and_the_search_criteria_are_populated

        click_on I18n.t("buttons.subscribe")
        expect(page).to have_content("There is a problem")

        fill_in_subscription_fields

        message_delivery = instance_double(ActionMailer::MessageDelivery)
        expect(Jobseekers::SubscriptionMailer).to receive(:confirmation) { message_delivery }
        expect(message_delivery).to receive(:deliver_later)
        click_on I18n.t("buttons.subscribe")
      end

      context "and the user submits a radius of 0 on the create a job alert page" do
        scenario "sets radius to a default radius" do
          fill_in_subscription_fields
          select I18n.t("jobs.search.number_of_miles", count: 0), from: "radius"

          click_on I18n.t("buttons.subscribe")

          expect(page).to have_content(I18n.t("jobs.search.number_of_miles", count: Search::RadiusBuilder::DEFAULT_RADIUS_FOR_POINT_SEARCHES))
        end
      end
    end
  end

  def and_click_job_alert_link
    if page.has_css?("#job-alert-link")
      click_on I18n.t("subscriptions.link.text")
    else
      click_on I18n.t("subscriptions.link.no_search_results.link")
    end
  end

  def and_perform_a_search
    within ".search-and-filters-form" do
      fill_in "keyword", with: "english"
      fill_in "location", with: location
      if search_with_polygons?
        select "25 miles", from: "radius"
      end
      check I18n.t("helpers.label.publishers_job_listing_job_details_form.job_roles_options.teacher")
      check I18n.t("jobs.filters.ect_suitable_only")
      check I18n.t("jobs.filters.send_responsible_only")
      check I18n.t("jobs.education_phase_options.primary")
      check I18n.t("helpers.label.publishers_job_listing_working_patterns_form.working_patterns_options.full_time")
      click_on I18n.t("buttons.search")
    end
  end

  def and_the_search_criteria_are_populated
    expect(page.find_field("jobseekers-subscription-form-keyword-field").value).to eq("english")
    expect(page.find_field("jobseekers-subscription-form-location-field").value).to eq(location)
    expect(page).to have_css(".location-finder__input")
    if search_with_polygons?
      expect(page.find_field("jobseekers-subscription-form-radius-field").value).to eq("25")
    end
    expect(page.find_field("jobseekers-subscription-form-job-roles-teacher-field")).to be_checked
    expect(page.find_field("jobseekers-subscription-form-job-roles-ect-suitable-field")).to be_checked
    expect(page.find_field("jobseekers-subscription-form-phases-primary-field")).to be_checked
    expect(page.find_field("jobseekers-subscription-form-working-patterns-full-time-field")).to be_checked
  end

  def fill_in_subscription_fields
    fill_in "jobseekers_subscription_form[email]", with: jobseeker.email unless jobseeker_signed_in?
    choose I18n.t("helpers.label.jobseekers_subscription_form.frequency_options.daily")
  end
end
