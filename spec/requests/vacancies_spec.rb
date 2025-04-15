require "rails_helper"

RSpec.describe "Vacancies" do
  describe "GET #index" do
    it "sets headers robots are asked to index but not to follow" do
      get job_path("signing_in")
      expect(response.headers["X-Robots-Tag"]).to eq("noarchive")
    end
  end

  describe "search filters for mobile rendering" do
    let(:request) { get jobs_path(params) }
    let(:params) { {} }
    let(:base_selector) { ".panel-component.js-action" }

    before { request }

    describe "show filter button" do
      let(:show_link) { "#{base_selector} a.panel-component__toggle.govuk-link" }

      it { assert_select(show_link, I18n.t("buttons.filters_toggle_panel")) }
    end

    describe "filter tags" do
      let(:tag_div) { "#{base_selector} .filters-list.panel-component__toggle" }
      let(:tags) { "#{base_selector} .filters-list.panel-component__toggle li" }

      it "when not filter set" do
        assert_select(tag_div, 1)
        assert_select(tags, 0)
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

        it "render tags" do
          assert_select(tag_div, 1)
          assert_select(tags, 1)
          assert_select(hidden_tag, I18n.t("shared.filter_group.remove_filter_hidden").strip)
          assert_select(tags, expected_tag_text)
        end
      end
    end
  end

  describe "GET #show" do
    subject { get job_path("missing-id") }

    context "when vacancy does not exist" do
      it "renders errors/not_found" do
        expect(subject).to render_template("errors/not_found")
      end

      it "returns not found" do
        subject
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
