require "rails_helper"

RSpec.describe Jobseekers::SearchResults::JobAlertsLinkComponent, type: :component do
  subject { described_class.new(vacancies_search: vacancies_search, count: 1) }

  let(:vacancies_search) { instance_double(Search::VacancySearch) }
  let(:active_hash) { { keyword: "maths" } }

  before do
    allow(vacancies_search).to receive(:active_criteria).and_return(active_hash)
    allow(vacancies_search).to receive(:active_criteria?).and_return(search_params_present?)
    allow(vacancies_search).to receive(:point_coordinates).and_return(true)
  end

  let!(:inline_component) { render_inline(subject) }

  context "when a search is carried out" do
    let(:search_params_present?) { true }

    it "renders the job alerts link" do
      expect(inline_component.css(
        "a#job-alert-link-sticky-gtm[href="\
        "'#{Rails.application.routes.url_helpers.new_subscription_path(search_criteria: active_hash, coordinates_present: true)}']",
      ).to_html).to include(I18n.t("subscriptions.link.text"))
    end
  end

  context "when a search is not carried out" do
    let(:search_params_present?) { false }

    it "does not render the job alerts link" do
      expect(rendered_component).to be_blank
    end
  end
end
