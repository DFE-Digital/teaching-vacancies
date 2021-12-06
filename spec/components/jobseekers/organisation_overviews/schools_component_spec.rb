require "rails_helper"

RSpec.describe Jobseekers::OrganisationOverviews::SchoolsComponent, type: :component do
  let!(:organisation) { create(:trust, schools: [school1, school2, school3]) }
  let(:geolocation_trait) { nil }
  let(:school1) { create(:school, geolocation_trait, name: "Oxford Uni", website: "https://this-is-a-test-url.example.com") }
  let(:school2) { create(:school, geolocation_trait, name: "Cambridge Uni") }
  let(:school3) { create(:school, geolocation_trait, name: "London LSE") }
  let(:vacancy) { create(:vacancy, :at_multiple_schools, organisations: [school1, school2, school3]) }
  let(:vacancy_presenter) { VacancyPresenter.new(vacancy) }

  let!(:inline_component) { render_inline(described_class.new(vacancy: vacancy_presenter)) }

  describe "#render?" do
    context "when vacancy job_location is central_office" do
      let(:vacancy) { create(:vacancy, :central_office) }

      it "does not render the component" do
        expect(rendered_component).to be_blank
      end
    end

    context "when vacancy job_location is at at_one_school" do
      let(:vacancy) { create(:vacancy, :at_one_school) }

      it "does not render the component" do
        expect(rendered_component).to be_blank
      end
    end

    context "when vacancy job_location is at_multiple_schools" do
      let(:vacancy) { create(:vacancy, :at_multiple_schools, organisations: [school1, school2, school3]) }

      it "renders the component" do
        expect(rendered_component).not_to be_blank
      end
    end
  end

  it "renders the school type" do
    expect(rendered_component).to include(vacancy.parent_organisation.group_type)
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

  it "renders all the school name in accordions" do
    [school1, school2, school3].each { |school| expect(rendered_component).to include(school.name) }
  end

  it "renders all the school types" do
    [school1, school2, school3].each { |school| expect(rendered_component).to include(organisation_type(school)) }
  end

  it "renders all the school education phases" do
    [school1, school2, school3].each { |school| expect(rendered_component).to include(school_phase(school)) }
  end

  it "renders all the school sizes" do
    [school1, school2, school3].each { |school| expect(rendered_component).to include(school_size(school)) }
  end

  it "renders all the school age ranges" do
    [school1, school2, school3].each { |school| expect(rendered_component).to include(age_range(school)) }
  end

  it "renders all the school ofsted_reports" do
    [school1, school2, school3].each { |school| expect(rendered_component).to include(ofsted_report(school)) }
  end

  it "renders all the school addresses" do
    [school1, school2, school3].each { |school| expect(rendered_component).to include(full_address(school)) }
  end

  context "when GIAS-provided website has been overwritten" do
    it "renders a link to the school website" do
      expect(rendered_component).to include(school1.website)
    end

    it "does not render the GIAS-provided website" do
      expect(rendered_component).not_to include(school1.url)
    end
  end

  it "renders all the GIAS-provided links to the school website section" do
    [school2, school3].each { |school| expect(rendered_component).to include(school.url) }
  end

  it "renders the school visits" do
    expect(rendered_component).to include(vacancy.school_visits)
  end

  context "when at least one school has a geolocation" do
    it "renders the location heading for multiple schools" do
      expect(rendered_component).to include("School locations")
    end

    it "shows the map element for Google Maps API to populate" do
      expect(inline_component.css("#map").count).to eq(1)
    end
  end

  context "when no school has a geolocation" do
    let(:geolocation_trait) { :no_geolocation }

    it "does not render the location heading for multiple schools" do
      expect(rendered_component).not_to include("School locations")
    end

    it "does not show the map" do
      expect(inline_component.css("#map").count).to eq(0)
    end
  end
end
