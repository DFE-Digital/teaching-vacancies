require "rails_helper"
require "dfe/analytics/rspec/matchers"

RSpec.describe "Jobseekers can create a job alert from a listing", recaptcha: true do
  let(:school) { create(:school, :secondary) }
  let(:vacancy) do
    create(:vacancy,
           :secondary,
           :ect_suitable,
           job_roles: ["teacher"],
           job_title: "Teacher",
           subjects: ["English"],
           working_patterns: ["full_time"],
           organisations: [school])
  end

  before do
    visit job_path(vacancy)
  end

  describe "creating a job alert" do
    before do
      click_on I18n.t("jobs.alert.similar.terse")
    end

    scenario "can click on the first link to create a job alert using data from the vacancy", :dfe_analytics do
      expect(:vacancy_create_job_alert_clicked).to have_been_enqueued_as_analytics_event(with_data: { vacancy_id: vacancy.id }) # rubocop:disable RSpec/ExpectActual

      expect(page).to have_content(I18n.t("subscriptions.new.title"))
      expect_search_criteria_to_be_populated
      click_on I18n.t("buttons.subscribe")
      expect(page).to have_content("There is a problem")

      fill_in_subscription_fields

      message_delivery = instance_double(ActionMailer::MessageDelivery)
      expect(Jobseekers::SubscriptionMailer).to receive(:confirmation) { message_delivery }
      expect(message_delivery).to receive(:deliver_later)
      click_on I18n.t("buttons.subscribe")
    end
  end

  scenario "can click on the second link to create a job alert using data from the vacancy", :dfe_analytics do
    click_on I18n.t("jobs.alert.similar.verbose.link_text")

    expect(:vacancy_create_job_alert_clicked).to have_been_enqueued_as_analytics_event(with_data: { vacancy_id: vacancy.id }) # rubocop:disable RSpec/ExpectActual
    expect_search_criteria_to_be_populated
  end

  def expect_search_criteria_to_be_populated
    expect(page.find_field("jobseekers-subscription-form-location-field").value).to eq(school.postcode)
    expect(page.find_field("jobseekers-subscription-form-radius-field").value).to eq(Search::CriteriaInventor::DEFAULT_RADIUS_IN_MILES.to_s)
    expect(page.find_field("jobseekers-subscription-form-teaching-job-roles-teacher-field")).to be_checked
    expect(page.find_field("jobseekers-subscription-form-ect-statuses-ect-suitable-field")).to be_checked
    expect(page.find_field("jobseekers-subscription-form-phases-secondary-field")).to be_checked
    expect(page.find_field("jobseekers-subscription-form-working-patterns-full-time-field")).not_to be_checked
  end

  def fill_in_subscription_fields
    fill_in "jobseekers_subscription_form[email]", with: Faker::Internet.email(domain: TEST_EMAIL_DOMAIN)
    choose I18n.t("helpers.label.jobseekers_subscription_form.frequency_options.daily")
  end
end
