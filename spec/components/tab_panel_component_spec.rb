require "rails_helper"

# These examples read the panel the way a publisher does. The table itself is covered by
# candidates_table_component_spec.rb. Use `page`, not `Capybara.string(render_inline(...))`:
# render_inline returns a Nokogiri fragment, which Capybara can't match fields against by label.
RSpec.describe TabPanelComponent, type: :component do
  include Rails.application.routes.url_helpers

  let(:component) { described_class.new(tab_name:, vacancy:, candidates:, form:, button_group:, displayed_fields:) }
  let(:tab_name) { "submitted" }
  let(:vacancy) { build_stubbed(:vacancy) }
  let(:form) { Publishers::JobApplication::TagForm.new }
  let(:button_group) { %i[update_status download] }
  let(:displayed_fields) { %i[name email_address status] }
  let(:candidates) { [build_stubbed(:job_application, :status_submitted, first_name: "Alice", last_name: "Archer", vacancy:)] }

  let(:flash_messages) { {} }

  before do
    flash_messages.each { |tab, message| vc_test_request.flash[tab] = message }
    render_inline(component)
  end

  it "groups the candidates under the tab's heading" do
    expect(page).to have_selector(:fieldset, "New applications")
  end

  context "when the tab has a hint" do
    let(:tab_name) { "interviewing" }
    let(:candidates) { [build_stubbed(:job_application, :status_interviewing, first_name: "Cara", last_name: "Clark", vacancy:)] }

    it "shows the hint" do
      expect(page).to have_text("Adding or changing the interview date and time on this page is for internal reference only.")
    end
  end

  it "lists the candidates for publishers to select" do
    expect(page).to have_field("Select Alice Archer", type: :checkbox)
  end

  describe "actions" do
    let(:button_group) { %i[update_status download message_shortlisted] }

    it "has a button for each action, in order" do
      expect(page.all("button").map(&:text)).to eq(["Update application status", "Download selected", "Send a message"])
    end

    # Styling, not behaviour, but it is the only signal of which action is the main one
    it "styles only the first action as the primary button" do
      expect(page).to have_no_button("Update application status", class: "govuk-button--secondary")
      expect(page).to have_button("Download selected", class: "govuk-button--secondary")
      expect(page).to have_button("Send a message", class: "govuk-button--secondary")
    end
  end

  # Publishers can't see this, but the tag action uses it to send them back to the right
  # tab. The form's URL and each button's tag_action are covered by the system specs that
  # press those buttons.
  describe "what the form submits" do
    it "says which tab it came from" do
      expect(page).to have_field("publishers_job_application_tag_form[origin]", type: :hidden, with: tab_name)
    end
  end

  context "when the form has errors" do
    let(:form) { Publishers::JobApplication::TagForm.new.tap(&:validate) }

    it "shows the error summary" do
      expect(page).to have_text("There is a problem")
      expect(page).to have_link(form.errors.messages_for(:job_applications).first)
    end
  end

  context "when there are error messages for more than one tab" do
    let(:flash_messages) { { "submitted" => "Select a new application", "offered" => "Select an offered application" } }

    # role="region" is how screen readers find the banner
    it "shows only this tab's message in the error banner" do
      expect(page).to have_css("[role='region']", exact_text: "Error Select a new application", normalize_ws: true)
    end
  end

  context "when there are no candidates" do
    let(:candidates) { [] }

    it "says so, instead of showing a table and actions" do
      expect(page).to have_text("There are no pending applications")
      expect(page).to have_no_table
      expect(page).to have_no_button
    end
  end
end
