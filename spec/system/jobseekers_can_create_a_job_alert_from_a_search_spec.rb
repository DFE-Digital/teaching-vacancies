require "rails_helper"

RSpec.describe "Jobseekers can create a job alert from a search" do
  let(:location) { nil }
  let(:location_category_search?) { false }
  let(:jobseeker_accounts_enabled?) { false }
  let(:jobseeker_signed_in?) { false }
  let(:jobseeker) { build_stubbed(:jobseeker) }

  before do
    allow(JobseekerAccountsFeature).to receive(:enabled?).and_return(jobseeker_accounts_enabled?)
  end

  describe "recaptcha" do
    context "when recaptcha score is invalid" do
      before do
        allow_any_instance_of(ApplicationController).to receive(:verify_recaptcha).and_return(true)
        allow_any_instance_of(ApplicationController).to receive(:recaptcha_reply).and_return({ "score" => 0.1 })
      end

      it "redirects to invalid_recaptcha path" do
        visit new_subscription_path(search_criteria: { keyword: "test" })
        click_on "Subscribe"
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

    context "when JobseekerAccountsFeature is disabled" do
      it "renders a link to search results" do
        click_on I18n.t("subscriptions.confirm.back_to_search_results")
        expect(current_path).to eq(jobs_path)
        expect(page.find_field("keyword").value).to eq("english")
      end
    end

    context "when JobseekerAccountsFeature is enabled" do
      let(:jobseeker_accounts_enabled?) { true }

      context "when jobseeker has an account" do
        let!(:jobseeker) { create(:jobseeker) }

        context "when jobseeker is signed in" do
          let(:jobseeker_signed_in?) { true }

          it "redirects to job alerts dashboard" do
            expect(current_path).to eq(jobseekers_subscriptions_path)
          end
        end

        context "when jobseeker is signed out" do
          it "renders a sign in prompt that redirects to job alerts dashboard" do
            within "div[data-account-prompt='sign-in']" do
              expect(page).to have_content(I18n.t("subscriptions.jobseeker_account_prompt.heading.sign_in"))
              click_on I18n.t("subscriptions.jobseeker_account_prompt.link.sign_in")
            end
            expect(current_path).to eq(new_jobseeker_session_path)
            sign_in_jobseeker
            expect(current_path).to eq(jobseekers_subscriptions_path)
          end
        end
      end

      context "when jobseeker does not have an account" do
        it "renders a create account prompt that redirects to job alerts dashboard" do
          within "div[data-account-prompt='sign-up']" do
            expect(page).to have_content(I18n.t("subscriptions.jobseeker_account_prompt.heading.sign_up"))
            click_on I18n.t("subscriptions.jobseeker_account_prompt.link.sign_up")
          end
          expect(current_path).to eq(new_jobseeker_registration_path)
          sign_up_jobseeker
          visit first_link_from_last_mail
          expect(current_path).to eq(jobseekers_subscriptions_path)
        end
      end
    end
  end

  describe "location search" do
    context "when a location category search is carried out" do
      let(:location_category_search?) { true }
      let(:location) { "London" }
      let!(:location_polygon) { create(:location_polygon, name: "london") }

      it "successfully creates a job alert" do
        visit jobs_path
        and_perform_a_search
        and_click_job_alert_link

        expect(page).to have_content(I18n.t("subscriptions.new.title"))
        and_the_search_criteria_are_populated

        click_on I18n.t("buttons.subscribe")
        expect(page).to have_content("There is a problem")

        fill_in_subscription_fields

        message_delivery = instance_double(ActionMailer::MessageDelivery)
        expect(SubscriptionMailer).to receive(:confirmation) { message_delivery }
        expect(message_delivery).to receive(:deliver_later)
        click_on I18n.t("buttons.subscribe")

        activities = PublicActivity::Activity.all
        keys = activities.pluck(:key)
        expect(keys).to include("subscription.alert.new")
        expect(keys).to include("subscription.daily_alert.create")
      end
    end

    context "when a location search is carried out" do
      let(:location_category_search?) { false }
      let(:location) { "SW1A 1AA" }

      it "successfully creates a job alert" do
        visit jobs_path
        and_perform_a_search
        and_click_job_alert_link

        expect(page).to have_content(I18n.t("subscriptions.new.title"))
        and_the_search_criteria_are_populated

        click_on I18n.t("buttons.subscribe")
        expect(page).to have_content("There is a problem")

        fill_in_subscription_fields

        message_delivery = instance_double(ActionMailer::MessageDelivery)
        expect(SubscriptionMailer).to receive(:confirmation) { message_delivery }
        expect(message_delivery).to receive(:deliver_later)
        click_on I18n.t("buttons.subscribe")

        activities = PublicActivity::Activity.all
        keys = activities.pluck(:key)
        expect(keys).to include("subscription.alert.new")
        expect(keys).to include("subscription.daily_alert.create")
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
    within ".filters-form" do
      fill_in "keyword", with: "english"
      fill_in "location", with: location
      if location_category_search?
        select "40 miles", from: "radius"
      end
      check I18n.t("helpers.label.job_details_form.job_roles_options.teacher")
      check I18n.t("helpers.label.job_details_form.job_roles_options.nqt_suitable")
      check I18n.t("helpers.label.job_details_form.working_patterns_options.full_time")
      click_on I18n.t("buttons.search")
    end
  end

  def and_the_search_criteria_are_populated
    expect(page.find_field("subscription-form-keyword-field").value).to eq("english")
    expect(page.find_field("subscription-form-location-field").value).to eq(location)
    if location_category_search?
      expect(page.find_field("subscription-form-radius-field").value).to eq("40")
    end
    expect(page.find_field("subscription-form-job-roles-teacher-field")).to be_checked
    expect(page.find_field("subscription-form-job-roles-nqt-suitable-field")).to be_checked
    expect(page.find_field("subscription-form-working-patterns-full-time-field")).to be_checked
  end

  def fill_in_subscription_fields
    fill_in "subscription_form[email]", with: jobseeker.email
    choose I18n.t("helpers.label.subscription_form.frequency_options.daily")
  end
end
