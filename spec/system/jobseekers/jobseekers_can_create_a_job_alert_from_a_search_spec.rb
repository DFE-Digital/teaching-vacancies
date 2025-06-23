require "rails_helper"

RSpec.describe "Jobseekers can create a job alert from a search", recaptcha: true do
  let(:location) { "London" }
  let!(:location_polygon) { create(:location_polygon, name: "london") }

  let(:search_with_polygons?) { false }
  let(:jobseeker_signed_in?) { false }
  let(:jobseeker) { build_stubbed(:jobseeker) }

  describe "recaptcha" do
    context "when recaptcha V3 check fails" do
      before do
        allow_any_instance_of(ApplicationController).to receive(:verify_recaptcha).and_return(false)
      end

      it "requests the user to pass a recaptcha V2 check" do
        visit new_subscription_path(search_criteria: { keyword: "test", location: "London" })
        fill_in_subscription_fields
        expect { click_on I18n.t("buttons.subscribe") }.not_to(change { Subscription.count })
        expect(page).to have_content("There is a problem")
        expect(page).to have_content(I18n.t("recaptcha.error"))
        expect(page).to have_content(I18n.t("recaptcha.label"))
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

    after { logout if jobseeker_signed_in? }

    context "when jobseeker has an account" do
      let!(:jobseeker) { create(:jobseeker) }

      context "when jobseeker is signed in" do
        let(:jobseeker_signed_in?) { true }

        scenario "redirects to job alerts dashboard" do
          expect(current_path).to eq(jobseekers_subscriptions_path)
        end
      end

      context "when jobseeker is signed out" do
        scenario "renders a sign in prompt that sends the user to GovUK One Login and redirects them back to the job alerts dashboard" do
          within "div[data-account-prompt='sign-in']" do
            expect(page).to have_content(I18n.t("subscriptions.jobseeker_account_prompt.heading.sign_in"))
            click_on I18n.t("buttons.sign_in")
          end
          sign_in_jobseeker_govuk_one_login(jobseeker)
          expect(current_path).to eq(jobseekers_subscriptions_path)
        end
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

    context "when a point location within the UK search is carried out" do
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

    context "when a point location outside the UK search is carried out" do
      let(:search_with_polygons?) { false }
      let(:location) { "Dublin" }

      before do
        allow(Geocoding).to receive(:new).with(location).and_return(instance_double(Geocoding, uk_coordinates?: false))
      end

      scenario "does not creates a job alert" do
        expect(page).to have_content(I18n.t("subscriptions.new.title"))
        and_the_search_criteria_are_populated

        fill_in_subscription_fields

        click_on I18n.t("buttons.subscribe")
        expect(page).to have_content("There is a problem")
        expect(page).to have_content("Enter a city, county or postcode in the UK")
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
  # i don't really like the method names starting with and
  def and_perform_a_search
    fill_in "keyword", with: "english"
    fill_in "location", with: location
    if search_with_polygons?
      select "25 miles", from: "radius"
    end
    find("summary", exact_text: I18n.t("jobs.filters.teaching_job_roles")).click
    check I18n.t("helpers.label.publishers_job_listing_job_role_form.job_role_options.teacher")
    check I18n.t("jobs.filters.ect_suitable")
    check I18n.t("helpers.label.publishers_job_listing_education_phases_form.phases_options.primary")
    check I18n.t("helpers.label.publishers_job_listing_contract_information_form.working_patterns_options.full_time")
    check I18n.t("jobs.filters.visa_sponsorship_availability.option")
    click_on I18n.t("buttons.search")
  end
# i don't really like the method names starting with and
  def and_the_search_criteria_are_populated
    expect(page.find_field("jobseekers-subscription-form-keyword-field").value).to eq("english")
    expect(page.find_field("jobseekers-subscription-form-location-field").value).to eq(location)
    expect(page).to have_css(".location-finder__input")
    if search_with_polygons?
      expect(page.find_field("jobseekers-subscription-form-radius-field").value).to eq("25")
    end
    expect(page.find_field("jobseekers-subscription-form-teaching-job-roles-teacher-field")).to be_checked
    expect(page.find_field("jobseekers-subscription-form-ect-statuses-ect-suitable-field")).to be_checked
    expect(page.find_field("jobseekers-subscription-form-phases-primary-field")).to be_checked
    expect(page.find_field("jobseekers-subscription-form-working-patterns-full-time-field")).to be_checked
    expect(page.find_field("jobseekers-subscription-form-visa-sponsorship-availability-true-field")).to be_checked
  end

  def fill_in_subscription_fields
    fill_in "jobseekers_subscription_form[email]", with: jobseeker.email unless jobseeker_signed_in?
    choose I18n.t("helpers.label.jobseekers_subscription_form.frequency_options.daily")
  end
end
