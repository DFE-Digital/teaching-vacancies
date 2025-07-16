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

    Jobseekers::JobApplication::PersonalDetailsForm.storable_fields.each do |field|
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

  describe "#error_path" do
    let(:kwargs) { { name: section_name } }

    context "when the job application is an uploaded job application" do
      let(:job_application) { create(:uploaded_job_application) }

      context "and the section name is :personal_details" do
        let(:section_name) { :personal_details }

        it "returns the correct edit path" do
          render_inline(component)
          expect(component.send(:error_path)).to eq(
            Rails.application.routes.url_helpers.edit_jobseekers_uploaded_job_application_personal_details_path(job_application),
          )
        end
      end

      context "and the section name is :upload_application_form" do
        let(:section_name) { :upload_application_form }

        it "returns the correct edit path" do
          render_inline(component)
          expect(component.send(:error_path)).to eq(
            Rails.application.routes.url_helpers.edit_jobseekers_uploaded_job_application_upload_application_form_path(job_application),
          )
        end
      end
    end

    context "when the job application is a standard application and persisted" do
      let(:job_application) { create(:job_application) }
      let(:section_name) { :personal_details }

      it "returns the standard build path" do
        render_inline(component)
        expect(component.send(:error_path)).to eq(
          Rails.application.routes.url_helpers.jobseekers_job_application_build_path(job_application, section_name),
        )
      end
    end

    context "when the job application is not uploaded and not persisted" do
      let(:job_application) do
        build(:job_application).tap do |ja|
          allow(ja).to receive_messages(persisted?: false)
        end
      end

      let(:section_name) { :personal_details }

      it "returns nil" do
        render_inline(component)
        expect(component.send(:error_path)).to be_nil
      end
    end
  end
end
