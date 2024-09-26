require "rails_helper"

RSpec.describe "Jobseekers can create a job alert from the v2 page", recaptcha: true do
  let(:jobseeker) { create(:jobseeker) }
  let(:subscription) { build(:subscription) }
  let(:search_criteria) { subscription.search_criteria }

  before do
    login_as(jobseeker, scope: :jobseeker)
    visit new_v2_subscriptions_path
  end

  after { logout }

  it "it does not create a job alert if no fields are filled in" do
    click_on I18n.t("buttons.subscribe")
    expect(page).to have_content("There is a problem")
  end

  it "does create a job alert when fields are filled in" do
    expect { create_a_job_alert }.to change { Subscription.count }.by(1)
    expect(current_path).to eq(jobseekers_subscriptions_path)
    expect(page).to have_content(I18n.t("subscriptions.create.success"))
    expect(page).to have_content("Keyword#{search_criteria['keyword']}")
  end

  def create_a_job_alert
    fill_in_subscription_fields
    click_on I18n.t("buttons.subscribe")
  end

  def fill_in_subscription_fields
    fill_in "jobseekers_subscription_form[keyword]", with: search_criteria["keyword"]
    fill_in "jobseekers_subscription_form[location]", with: search_criteria["location"]
    select I18n.t("jobs.search.number_of_miles", count: search_criteria["radius"])
    choose I18n.t("helpers.label.jobseekers_subscription_form.frequency_options.#{subscription.frequency}")
    search_criteria["working_patterns"].each do |working_pattern|
      check I18n.t("helpers.label.publishers_job_listing_working_patterns_form.working_patterns_options.#{working_pattern}")
    end
    find("summary span[aria-label='Teaching & leadership job roles']").click
    search_criteria["teaching_job_roles"].each do |job_role|
      check I18n.t("helpers.label.publishers_job_listing_job_role_form.job_role_options.#{job_role}")
    end
    find("summary span[aria-label='Support job roles']").click
    search_criteria["support_job_roles"].each do |job_role|
      check I18n.t("helpers.label.publishers_job_listing_job_role_form.support_job_role_options.#{job_role}")
    end
    search_criteria["phases"].each do |phase|
      check I18n.t("helpers.label.publishers_job_listing_education_phases_form.phases_options.#{phase}")
    end
  end
end
