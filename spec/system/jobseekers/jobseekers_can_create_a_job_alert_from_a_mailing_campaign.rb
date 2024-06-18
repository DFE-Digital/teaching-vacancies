require "rails_helper"

RSpec.describe "Jobseekers can create a job alert from a mailing campaign", :recaptcha do
  let(:params) { { email_contact: "user@example.com", email_postcode: "SW24LP" } }

  describe "when recaptcha V3 check fails" do
    before do
      allow_any_instance_of(ApplicationController).to receive(:verify_recaptcha).and_return(false)
    end

    it "requests the user to pass a recaptcha V2 check" do
      visit new_subscription_path(params:)
      choose I18n.t("helpers.label.jobseekers_subscription_form.frequency_options.daily")

      expect { click_on I18n.t("buttons.subscribe_campaign") }.not_to(change(Subscription, :count))
      expect(page).to have_content("There is a problem")
      expect(page).to have_content(I18n.t("recaptcha.error"))
      expect(page).to have_content(I18n.t("recaptcha.label"))
    end
  end

  it "the landing form has default values when not set from the URL parameters" do
    visit new_subscription_path(params:)

    expect(page).to have_css("h1", text: "Welcome to Teaching Vacancies!", exact_text: true)
    expect(page).to have_css("p", text: "Get teaching jobs sent straight to your inbox.")
    expect(page).to have_field("City, county or postcode (in England)", with: "SW24LP")
                .and have_field("Email address", with: "user@example.com")
                .and have_field("Search radius", with: "15")
                .and have_checked_field("Teacher")
                .and have_checked_field("Suitable for early career teachers")
                .and have_checked_field("Full time")

    validate_and_confirm
  end

  it "the subscription form values are set from the URL parameters" do
    visit new_subscription_path(params: {
      email_name: "Ali",
      email_contact: "user@example.com",
      email_postcode: "SW24LP",
      email_subject: "mathematics",
      email_phase: "primary",
      email_radius: "10",
      email_jobrole: "assistant_headteacher",
      email_working_pattern: "part_time",
    })

    expect(page).to have_css("h1", text: "Hey Ali, welcome to Teaching Vacancies!", exact_text: true)
    expect(page).to have_css("p", text: "Get mathematics teacher jobs sent straight to your inbox.")
    expect(page).to have_field("City, county or postcode (in England)", with: "SW24LP")
                .and have_field("Email address", with: "user@example.com")
                .and have_field("Search radius", with: "10")
                .and have_checked_field("Assistant headteacher")
                .and have_checked_field("Mathematics")
                .and have_checked_field("Suitable for early career teachers")
                .and have_checked_field("Primary school")
                .and have_checked_field("Part time")

    expect(page).to have_no_checked_field("Teacher")
    expect(page).to have_no_checked_field("Full time")

    validate_and_confirm
  end

  def validate_and_confirm
    click_button I18n.t("buttons.subscribe_campaign")
    expect(page).to have_content("There is a problem")
                .and have_content("Select when you want to receive job alert emails")

    choose I18n.t("helpers.label.jobseekers_subscription_form.frequency_options.daily")
    click_button I18n.t("buttons.subscribe_campaign")
    expect(page).to have_current_path(subscriptions_path, ignore_query: true)
    expect(page).to have_content(I18n.t("subscriptions.confirm.header.create"))
  end
end
