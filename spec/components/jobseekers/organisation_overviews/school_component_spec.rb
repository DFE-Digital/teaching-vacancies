require "rails_helper"

RSpec.describe Jobseekers::OrganisationOverviews::SchoolComponent, type: :component do
  let(:geolocation_trait) { nil }
  let(:organisation) { create(:school, geolocation_trait) }
  let(:vacancy) { create(:vacancy, :at_one_school, organisations: [organisation]) }
  let(:vacancy_presenter) { VacancyPresenter.new(vacancy) }

  let!(:inline_component) do
    render_inline(described_class.new(vacancy: vacancy_presenter))
  end

  describe "#render?" do
    context "when vacancy is at a trust head office" do
      let(:organisation) { create(:trust) }
      let(:vacancy) { create(:vacancy, :central_office) }

      it "does not render the component" do
        expect(rendered_component).to be_blank
      end
    end

    context "when vacancy is at a single school in a trust" do
      let(:vacancy) { create(:vacancy, :at_one_school, organisations: [organisation]) }

      it "renders the component" do
        expect(rendered_component).not_to be_blank
      end
    end
  end

  context "rendering the school type" do
    it "renders the school type" do
      expect(rendered_component).to include(organisation_type(vacancy.parent_organisation))
    end
  end

  it "renders the education phase" do
    expect(rendered_component).to include(school_phase(vacancy.parent_organisation))
  end

  context "when the number of pupils is present" do
    it "renders the school size as the number of pupils" do
      expect(rendered_component).to include(school_size(vacancy.parent_organisation))
    end
  end

  context "when the number of pupils is not present" do
    context "when the school capacity is present" do
      let(:organisation) { create(:school, gias_data: { "NumberOfPupils" => nil, "SchoolCapacity" => 1000 }) }

      it "renders the school capacity as the school size" do
        expect(rendered_component).to include(school_size(vacancy.parent_organisation))
      end
    end

    context "when the school capacity is not present" do
      let(:organisation) { create(:school, gias_data: { "NumberOfPupils" => nil, "SchoolCapacity" => nil }) }

      it "renders the school no information translation" do
        expect(rendered_component).to include(school_size(vacancy.parent_organisation))
      end
    end
  end

  it "renders the osted report" do
    expect(rendered_component).to include(ofsted_report(vacancy.parent_organisation))
  end

  context "when GIAS-obtained website has been overwritten" do
    let(:organisation) { create(:school, website: "https://this-is-a-test-url.example.com") }

    it "renders a link to the school website" do
      expect(rendered_component).to include(vacancy.parent_organisation.website)
    end
  end

  it "renders a link to the school website" do
    expect(rendered_component).to include(vacancy.parent_organisation.url)
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

  it "renders school visits" do
    expect(rendered_component).to include(vacancy.school_visits)
  end

  it "renders the head office location" do
    expect(rendered_component).to include(full_address(vacancy.parent_organisation))
  end

  context "when the school has a geolocation" do
    it "renders the location heading for a singular school" do
      expect(rendered_component).to include("School location")
    end

    it "shows the map element for Google Maps API to populate" do
      expect(inline_component.css("#map").count).to eq(1)
    end
  end

  context "when school has no geolocation" do
    let(:geolocation_trait) { :no_geolocation }

    it "does not render the location heading for a singular school" do
      expect(rendered_component).not_to include("School locations")
    end

    it "does not show the map" do
      expect(inline_component.css("#map").count).to eq(0)
    end
  end

  describe "#organisation_map_data" do
    let(:data) do
      JSON.parse(described_class.new(vacancy: vacancy_presenter).organisation_map_data)
    end

    it "contains the school name" do
      expect(data["name"]).to eq organisation.name
    end

    it "contains the school latitude" do
      expect(data["lat"].round(13)).to eq organisation.geopoint.lat.round(13)
    end

    it "contains the school longitude" do
      expect(data["lng"].round(13)).to eq organisation.geopoint.lon.round(13)
    end
  end
end
