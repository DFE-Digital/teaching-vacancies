require "rails_helper"

RSpec.describe "Jobseekers can create a job alert from a mailing campaign", recaptcha: true do
  let(:params) { { email_contact: "user@example.com", email_postcode: "SW24LP" } }

  describe "when recaptcha V3 check fails" do
    before do
      allow_any_instance_of(ApplicationController).to receive(:verify_recaptcha).and_return(false)
    end

    it "requests the user to pass a recaptcha V2 check" do
      visit new_subscription_path(params:)
      choose I18n.t("helpers.label.jobseekers_subscription_form.frequency_options.daily")

      expect { click_on I18n.t("buttons.subscribe") }.not_to(change { Subscription.count })
      expect(page).to have_content("There is a problem")
      expect(page).to have_content(I18n.t("recaptcha.error"))
      expect(page).to have_content(I18n.t("recaptcha.label"))
    end
  end

  scenario "the landing form has default values for radio, job role, ect suitability and working pattern" do
    visit new_subscription_path(params:)

    expect(page).to have_field("Location", with: "SW24LP")
                .and have_field("Email address", with: "user@example.com")
                .and have_field("Search radius", with: "15")
                .and have_checked_field("Teacher")
                .and have_checked_field("Suitable for early career teachers")
                .and have_checked_field("Full time")
  end

  scenario "the subscription form values are set from the URL parameters" do
    visit new_subscription_path(params: {
      email_contact: "user@example.com",
      email_postcode: "SW24LP",
      email_subject: "mathematics",
      email_phase: "primary",
      email_radius: "10",
      email_jobrole: "assistant_headteacher",
      email_working_pattern: "part_time",
    })

    expect(page).to have_field("Location", with: "SW24LP")
                .and have_field("Email address", with: "user@example.com")
                .and have_field("Search radius", with: "10")
                .and have_checked_field("Assistant headteacher")
                .and have_checked_field("Mathematics")
                .and have_checked_field("Suitable for early career teachers")
                .and have_checked_field("Primary school")
                .and have_checked_field("Part time")

    expect(page).not_to have_checked_field("Teacher")
    expect(page).not_to have_checked_field("Full time")
  end
end
