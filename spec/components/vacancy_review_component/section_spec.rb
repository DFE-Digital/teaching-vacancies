require "rails_helper"

RSpec.describe VacancyReviewComponent::Section, type: :component do
  subject(:component) { described_class.new(*args, **kwargs) }

  let(:args) { [vacancy] }
  let(:kwargs) do
    {
      name:,
      id:,
      back_to:,
    }
  end

  let(:vacancy) { create(:vacancy, :draft) }
  let(:back_to) { "review" }
  let(:id) { nil }
  let(:name) { :job_details }

  it_behaves_like ReviewComponent::Section

  it "uses the section name to find the form by default" do
    render_inline(component)

    Publishers::JobListing::JobDetailsForm.fields.each do |field|
      expect(page).to have_css("div##{field}")
    end
  end

  context "when forms are provided" do
    let(:kwargs) do
      {
        name: :job_details,
        forms: %w[
          PayPackageForm
          WorkingPatternsForm
        ],
      }
    end

    it "uses the fields from the provided forms" do
      render_inline(component)

      Publishers::JobListing::PayPackageForm.fields.each do |field|
        expect(page).to have_css("div##{field}")
      end

      Publishers::JobListing::WorkingPatternsForm.fields.each do |field|
        expect(page).to have_css("div##{field}")
      end
    end
  end

  describe "The section heading" do
    before do
      render_inline(component)
    end

    it "renders the heading component" do
      expect(page).to have_css("li > ##{name} > .review-component__section__heading")
    end

    it "renders the title" do
      expect(page).to have_css(
        ".review-component__section__heading > .review-component__section__heading__title > h3",
        text: component.t("publishers.vacancies.steps.job_details"),
      )
    end

    it "renders a link to the form for that section" do
      url = Rails.application.routes.url_helpers.organisation_job_build_path(vacancy.id, name, back_to:)
      text = component.t("buttons.change")

      expect(page).to have_css(".review-component__section__heading a[href='#{url}']", text:)
    end

    it "renders a status tag as the content" do
      expect(page).to have_css(".review-component__section__heading .review-component__section__heading__status .govuk-tag")
    end
  end

  describe "The main list" do
    it "does not render the list by default" do
      render_inline(component)

      expect(page).not_to have_css(".govuk-summary-list")
    end

    context "when rows are defined" do
      before do
        render_inline(component) do |section|
          section.row(:job_title)
          section.row(:contract_type)
        end
      end

      it "renders the list with the rows" do
        expect(page).to have_css(".review-component__section__body .govuk-summary-list")
        expect(page).to have_css(".govuk-summary-list__row", count: 2)
      end
    end
  end
end
