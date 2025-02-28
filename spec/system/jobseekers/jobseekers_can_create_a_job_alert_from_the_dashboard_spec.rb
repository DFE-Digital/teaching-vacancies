require "rails_helper"

RSpec.describe "Jobseekers can create a job alert from the dashboard", recaptcha: true do
  let(:jobseeker) { create(:jobseeker) }
  let(:subscription) { build(:subscription, :with_some_criteria) }
  let(:search_criteria) { subscription.search_criteria }

  before do
    login_as(jobseeker, scope: :jobseeker)
  end

  after { logout }

  context "when the jobseeker has no job alerts" do
    before { visit jobseekers_subscriptions_path }

    it "displays the no job alerts notification component" do
      expect(page).to have_content(I18n.t("jobseekers.subscriptions.index.zero_subscriptions_title"))
      expect(page).to have_content(I18n.t("jobseekers.subscriptions.index.link_create"))
    end

    it "creates a job alert and redirects to the subscriptions index page" do
      within ".empty-section-component" do
        click_on I18n.t("jobseekers.subscriptions.index.link_create")
      end
      an_invalid_form_is_rejected
      expect { create_a_job_alert }.to change { Subscription.count }.by(1)
      and_the_job_alert_is_on_the_index_page
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
  end

  context "when the jobseeker has job alerts" do
    let!(:created_subscription) { create(:subscription, email: jobseeker.email) }

    before { visit jobseekers_subscriptions_path }

    it "displays the create job alert button" do
      expect(page).to have_content(I18n.t("jobseekers.subscriptions.index.button_create"))
    end

    it "creates a job alert and redirects to the subscriptions index page" do
      within "#subscriptions-results" do
        click_on I18n.t("jobseekers.subscriptions.index.button_create")
      end
      an_invalid_form_is_rejected
      expect { create_a_job_alert }.to change { Subscription.count }.by(1)
      and_the_job_alert_is_on_the_index_page
    end
  end

  def an_invalid_form_is_rejected
    click_on I18n.t("buttons.subscribe")
    expect(page).to have_content("There is a problem")
  end

  def and_the_job_alert_is_on_the_index_page
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
    find('summary', text: 'Teaching & leadership').click
    search_criteria["teaching_job_roles"].each do |job_role|
      check I18n.t("helpers.label.publishers_job_listing_job_role_form.job_role_options.#{job_role}")
    end
    find('summary', text: 'Support').click
    search_criteria["support_job_roles"].each do |job_role|
      check I18n.t("helpers.label.publishers_job_listing_job_role_form.support_job_role_options.#{job_role}")
    end
    search_criteria["phases"].each do |phase|
      check I18n.t("helpers.label.publishers_job_listing_education_phases_form.phases_options.#{phase}")
    end
  end
end
