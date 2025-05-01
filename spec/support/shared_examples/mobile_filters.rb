RSpec.shared_examples "a rendered mobile search filter component" do |search_params, filter_text|
  let(:search_criteria) { {} }

  describe "filter mobile display" do
    let(:base_selector) { ".panel-component.js-action" }
    let(:show_link) { "#{base_selector} a.panel-component__toggle.govuk-link" }

    it "displays the show filter button" do
      expect(rendered).to have_css(show_link, text: I18n.t("buttons.filters_toggle_panel"))
    end
  end

  describe "filter tags" do
    let(:base_selector) { ".panel-component.js-action" }
    let(:tag_div) { "#{base_selector} .filters-list.panel-component__toggle" }
    let(:tags) { "#{base_selector} .filters-list.panel-component__toggle li" }

    context "when no filters are set" do
      it "renders the filter container but no tags" do
        expect(rendered).to have_css(tag_div)
        expect(rendered).to have_no_css(tags)
      end
    end

    context "when search criteria is set" do
      let(:search_criteria) { search_params }
      let(:hidden_tag) { "#{base_selector} .filters-list.panel-component__toggle li span" }
      let(:expected_tag_text) do
        [
          I18n.t("shared.filter_group.remove_filter_hidden"),
          filter_text,
        ].join
      end

      it "renders the appropriate filter tags" do
        expect(rendered).to have_css(tag_div)
        expect(rendered).to have_css(tags)
        expect(rendered).to have_css(hidden_tag, text: I18n.t("shared.filter_group.remove_filter_hidden").strip)
        expect(rendered).to have_css(tags, text: expected_tag_text)
      end
    end
  end
end
