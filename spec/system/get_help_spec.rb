require "rails_helper"

RSpec.describe "Requesting support", recaptcha: true, vcr: true, zendesk: true do
  let(:issue) { "Help!" }
  let(:email) { "test@example.com" }

  context "when all required fields are complete" do
    scenario "can request support" do
      visit root_path

      click_on "Get help or report a problem"

      expect(page).to have_content("Get help")

      fill_in_required_fields

      click_on "Send message"

      expect(page).to have_content(I18n.t("support_requests.create.success"))
    end

    scenario "can specify a page" do
      visit root_path

      click_on "Get help or report a problem"

      expect(page).to have_content("Get help")

      fill_in_required_fields(page: "Some page")

      click_on "Send message"

      expect(page).to have_content(I18n.t("support_requests.create.success"))
    end

    scenario "can add a screenshot" do
      visit root_path

      click_on "Get help or report a problem"

      expect(page).to have_content("Get help")

      fill_in_required_fields(screenshot: Rails.root.join("spec/fixtures/files/blank_job_spec.pdf"))

      click_on "Send message"

      expect(page).to have_content(I18n.t("support_requests.create.success"))
    end
  end

  context "when all required fields are not complete" do
    scenario "can not request support" do
      visit root_path

      click_on "Get help or report a problem"
      click_on "Send message"

      expect(page).to have_content("There is a problem")
    end
  end

  context "when recaptcha is invalid" do
    before do
      allow_any_instance_of(ApplicationController).to receive(:verify_recaptcha).and_return(false)
    end

    context "and the form is valid" do
      scenario "redirects to invalid_recaptcha path" do
        visit root_path

        click_on "Get help or report a problem"

        expect(page).to have_content("Get help")

        fill_in_required_fields

        click_on "Send message"

        expect(page).to have_current_path(invalid_recaptcha_path(form_name: "Support request form"))
      end
    end

    context "and the form is invalid" do
      scenario "does not redirect to invalid_recaptcha path" do
        visit root_path

        click_on "Get help or report a problem"
        click_on "Send message"

        expect(page).to have_content("There is a problem")
      end
    end
  end

  def fill_in_required_fields(page: nil, screenshot: nil)
    fill_in "Name", with: "User In-Need"
    fill_in "Email", with: email

    if page
      choose "A specific page"
      fill_in "Enter the URL or the name of the page", with: page
    else
      choose "The whole site"
    end

    fill_in "Tell us about your problem or question", with: issue

    attach_file "Upload a file", screenshot if screenshot
  end
end
