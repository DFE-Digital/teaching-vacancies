require "rails_helper"

RSpec.describe Jobseekers::OrganisationOverviews::SchoolGroupComponent, type: :component do
  let(:organisation) { create(:trust, name: "Cambridge Uni") }
  let(:vacancy) { create(:vacancy, :central_office, organisations: [organisation]) }
  let(:vacancy_presenter) { VacancyPresenter.new(vacancy) }

  before do
    render_inline(described_class.new(vacancy: vacancy_presenter))
  end

  describe "#render?" do
    context "when vacancy is at a school without a trust" do
      let(:organisation) { create(:school, name: "Cambridge Uni") }
      let(:vacancy) { create(:vacancy, organisations: [organisation]) }

      it "does not render the component" do
        expect(rendered_component).to be_blank
      end
    end

    context "when vacancy is at a single school in a trust" do
      let(:vacancy) { create(:vacancy, :at_one_school, organisations: [organisation]) }

      it "does not render the component" do
        expect(rendered_component).to be_blank
      end
    end

    context "when vacancy is at a trust head office" do
      it "renders the component" do
        expect(rendered_component).not_to be_blank
      end
    end
  end

  it "renders the trust type" do
    expect(rendered_component).to include(organisation_type(vacancy.parent_organisation))
  end

  it "renders a link to the trust website" do
    expect(rendered_component).to include(vacancy.parent_organisation.website)
  end

  it "renders the contact email" do
    expect(rendered_component).to include(vacancy.contact_email)
  end

  it "renders the contact number" do
    expect(rendered_component).to include(vacancy.contact_number)
  end

  it "renders about school or organisation description" do
    expect(rendered_component).to include(vacancy_or_organisation_description(vacancy))
  end

  # TODO: school_visits needs to be changed to organisation_visits
  it "renders school visits" do
    expect(rendered_component).to include(vacancy.school_visits)
  end

  it "renders the head office location" do
    expect(rendered_component).to include(full_address(vacancy.parent_organisation))
  end
end
