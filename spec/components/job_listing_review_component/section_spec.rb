require "rails_helper"

RSpec.describe JobApplicationReviewComponent::Section, type: :component do
  subject(:component) { described_class.new(*args, **kwargs) }

  let(:args) { [job_application] }
  let(:kwargs) do
    {
      name: name,
      id: id,
    }
  end

  let(:job_application) { create(:job_application, :draft) }
  let(:id) { nil }
  let(:name) { :personal_details }

  it_behaves_like ReviewComponent::Section

  it "uses the section name to find the form by default" do
    render_inline(component)

    Jobseekers::JobApplication::PersonalDetailsForm.fields.each do |field|
      expect(page).to have_css("div##{field}")
    end
  end

  context "when forms are provided" do
    let(:kwargs) do
      {
        name: :personal_details,
        forms: %w[
          DeclarationsForm
          ProfessionalStatusForm
        ],
      }
    end

    it "uses the fields from the provided forms" do
      render_inline(component)

      Jobseekers::JobApplication::DeclarationsForm.fields.each do |field|
        expect(page).to have_css("div##{field}")
      end

      Jobseekers::JobApplication::ProfessionalStatusForm.fields.each do |field|
        expect(page).to have_css("div##{field}")
      end
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
          section.with_row
          section.with_row
        end
      end

      it "renders the list with the rows" do
        expect(page).to have_css(".review-component__section__body .govuk-summary-list")
        expect(page).to have_css(".govuk-summary-list__row", count: 2)
      end
    end
  end
end
