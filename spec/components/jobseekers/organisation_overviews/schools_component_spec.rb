require 'rails_helper'

RSpec.describe Jobseekers::OrganisationOverviews::SchoolsComponent, type: :component do
  let(:organisation) { create(:trust) }
  let(:geolocation_trait) { nil }
  let(:school_1) { create(:school, geolocation_trait, name: 'Oxford Uni', website: 'https://this-is-a-test-url.tvs') }
  let(:school_2) { create(:school, geolocation_trait, name: 'Cambridge Uni') }
  let(:school_3) { create(:school, geolocation_trait, name: 'London LSE') }

  let(:vacancy) do
    create(:vacancy, :at_multiple_schools, organisation_vacancies_attributes: [
      { organisation: school_1 }, { organisation: school_2 }, { organisation: school_3 }
    ])
  end
  let(:vacancy_presenter) { VacancyPresenter.new(vacancy) }

  before do
    organisation.school_group_memberships.create(school: school_1)
    organisation.school_group_memberships.create(school: school_2)
    organisation.school_group_memberships.create(school: school_3)
    render_inline(described_class.new(vacancy: vacancy_presenter))
  end

  describe '#render?' do
    context 'when vacancy job_location is central_office' do
      let(:vacancy) { create(:vacancy, :central_office) }

      it 'does not render the component' do
        expect(rendered_component).to be_blank
      end
    end

    context 'when vacancy job_location is at at_one_school' do
      let(:vacancy) { create(:vacancy, :at_one_school) }

      it 'does not render the component' do
        expect(rendered_component).to be_blank
      end
    end

    context 'when vacancy job_location is at_multiple_schools' do
      let(:vacancy) do
        create(:vacancy, :at_multiple_schools, organisation_vacancies_attributes: [
          { organisation: school_1 }, { organisation: school_2 }, { organisation: school_3 }
        ])
      end

      it 'renders the component' do
        expect(rendered_component).not_to be_blank
      end
    end
  end

  it 'renders the school type' do
    expect(rendered_component).to include(vacancy.parent_organisation.group_type)
  end

  it 'renders the contact email' do
    expect(rendered_component).to include(vacancy.contact_email)
  end

  it 'renders the contact number' do
    expect(rendered_component).to include(vacancy.contact_number)
  end

  it 'renders about school or organisation description' do
    expect(rendered_component).to include(vacancy_or_organisation_description(vacancy))
  end

  it 'renders all the school name in accordions' do
    [school_1, school_2, school_3].each { |school| expect(rendered_component).to include(school.name) }
  end

  it 'renders all the school types' do
    [school_1, school_2, school_3].each do |school|
      expect(rendered_component).to include(organisation_type(organisation: school, with_age_range: false))
    end
  end

  it 'renders all the school education phases' do
    [school_1, school_2, school_3].each { |school| expect(rendered_component).to include(school_phase(school)) }
  end

  it 'renders all the school sizes' do
    [school_1, school_2, school_3].each { |school| expect(rendered_component).to include(school_size(school)) }
  end

  it 'renders all the school age ranges' do
    [school_1, school_2, school_3].each { |school| expect(rendered_component).to include(age_range(school)) }
  end

  it 'renders all the school ofsted_reports' do
    [school_1, school_2, school_3].each { |school| expect(rendered_component).to include(ofsted_report(school)) }
  end

  it 'renders all the school addresses' do
    [school_1, school_2, school_3].each { |school| expect(rendered_component).to include(full_address(school)) }
  end

  context 'when GIAS-provided website has been overwritten' do
    it 'renders a link to the school website' do
      expect(rendered_component).to include(school_1.website)
    end

    it 'does not render the GIAS-provided website' do
      expect(rendered_component).not_to include(school_1.url)
    end
  end

  it 'renders all the GIAS-provided links to the school website section' do
    [school_2, school_3].each { |school| expect(rendered_component).to include(school.url) }
  end

  it 'renders the school visits' do
    expect(rendered_component).to include(vacancy.school_visits)
  end

  context 'when at least one school has a geolocation' do
    it 'renders the location heading for multiple schools' do
      expect(rendered_component).to include('School locations')
    end

    it 'shows the map element for Google Maps API to populate' do
      expect(rendered_component).to include('map')
    end
  end

  context 'when no school has a geolocation' do
    let(:geolocation_trait) { :no_geolocation }

    it 'does not render the location heading for multiple schools' do
      expect(rendered_component).not_to include('School locations')
    end

    it 'does not show the map' do
      expect(rendered_component).not_to include('map')
    end
  end

  describe '#organisation_map_data' do
    let(:organisation_map_data) do
       JSON.parse(described_class.new(vacancy: vacancy_presenter).organisation_map_data)
    end

    let(:school_1_data) do
      organisation_map_data.select { |s| s['name'] == school_1.name }.first
    end

    let(:school_2_data) do
      organisation_map_data.select { |s| s['name'] == school_2.name }.first
    end

    context 'when the user has provided a website' do
      it 'links to the user-provided website' do
        expect(school_1_data['name_link']).to eq "<a href=\"#{school_1.website}\">#{school_1.name}</a>"
      end
    end

    context 'when the user has NOT provided a website' do
      it 'links to the GIAS-provided url' do
        expect(school_2_data['name_link']).to eq "<a href=\"#{school_2.url}\">#{school_2.name}</a>"
      end
    end
  end
end
