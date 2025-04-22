require "rails_helper"

RSpec.describe "Jobseeker job search filter mobile display" do
  let(:request) { visit jobs_path(params) }
  let(:params) { {} }
  let(:base_selector) { ".panel-component.js-action" }

  before do
    Capybara.current_driver = :rack_test
    request
  end

  after { Capybara.use_default_driver }

  describe "show filter button" do
    let(:show_link) { "#{base_selector} a.panel-component__toggle.govuk-link" }

    it { expect(page).to have_css(show_link, text: I18n.t("buttons.filters_toggle_panel")) }
  end

  describe "filter tags" do
    let(:tag_div) { "#{base_selector} .filters-list.panel-component__toggle" }
    let(:tags) { "#{base_selector} .filters-list.panel-component__toggle li" }

    it "when not filter set nothing rendered" do
      expect(page).to have_css(tag_div)
      expect(page).to have_no_css(tags)
    end

    context "when visa_sponsorship_availability set" do
      let(:params) { { visa_sponsorship_availability: %w[true] } }

      let(:hidden_tag) { "#{base_selector} .filters-list.panel-component__toggle li span" }
      let(:expected_tag_text) do
        [
          I18n.t("shared.filter_group.remove_filter_hidden"),
          I18n.t("jobs.filters.visa_sponsorship_availability.option"),
        ].join
      end

      it "renders tags" do
        expect(page).to have_css(tag_div)
        expect(page).to have_css(tags)
        expect(page).to have_css(hidden_tag, text: I18n.t("shared.filter_group.remove_filter_hidden").strip)
        expect(page).to have_css(tags, text: expected_tag_text)
      end
    end
  end
end
