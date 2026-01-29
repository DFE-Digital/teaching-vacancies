require "rails_helper"

RSpec.describe "Jobseekers can create a job alert from the dashboard", recaptcha: true do
  let(:jobseeker) { create(:jobseeker) }
  let(:subscription) { build(:subscription, :with_some_criteria) }
  let(:search_criteria) { subscription.search_criteria }

  before do
    login_as(jobseeker, scope: :jobseeker)
    visit jobseekers_subscriptions_path
  end

  after { logout }

  it "creates a job alert and redirects to the subscriptions index page" do
    within ".empty-section-component" do
      click_on I18n.t("jobseekers.subscriptions.index.link_create")
    end

    click_on I18n.t("buttons.subscribe")
    expect(page).to have_content("There is a problem")
    within "ul.govuk-list.govuk-error-summary__list" do
      expect(page).to have_link("Select when you want to receive job alert emails")
      expect(page).to have_link("Enter a location and one or more other filters, for example a keyword or job role.")
    end

    expect { create_a_job_alert }.to change { Subscription.count }.by(1)
    expect(current_path).to eq(jobseekers_subscriptions_path)
    expect(page).to have_content(I18n.t("subscriptions.create.success"))
    expect(page).to have_content("Keyword#{search_criteria['keyword']}")
  end

  context "when recaptcha V3 check fails" do
    before do
      allow_any_instance_of(ApplicationController).to receive(:verify_recaptcha).and_return(false)
    end

    it "requests the user to pass a recaptcha V2 check" do
      within ".empty-section-component" do
        click_on I18n.t("jobseekers.subscriptions.index.link_create")
      end

      expect { create_a_job_alert }.not_to(change { Subscription.count })
      expect(page).to have_content("There is a problem")
      expect(page).to have_content(I18n.t("recaptcha.error"))
      expect(page).to have_content(I18n.t("recaptcha.label"))
    end
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
      check I18n.t("helpers.label.publishers_job_listing_contract_information_form.working_patterns_options.#{working_pattern}")
    end
    find("summary", text: "Teaching and leadership").click
    search_criteria["teaching_job_roles"].each do |job_role|
      check I18n.t("helpers.label.publishers_job_listing_job_role_form.job_role_options.#{job_role}")
    end
    find("summary", text: "Support").click
    search_criteria["support_job_roles"].each do |job_role|
      check I18n.t("helpers.label.publishers_job_listing_job_role_form.support_job_role_options.#{job_role}")
    end
    search_criteria["phases"].each do |phase|
      check I18n.t("helpers.label.publishers_job_listing_education_phases_form.phases_options.#{phase}")
    end
  end
end
