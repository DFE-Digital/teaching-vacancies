require 'rails_helper'

RSpec.describe Jobseekers::SchoolsOverviewComponent, type: :component do
  let(:school_group) { create(:school_group) }
  let(:geolocation_trait) { nil }
  let(:school_1) do
    create(:school, geolocation_trait, name: 'Oxford Uni',
                                       gias_data: { 'URN' => Faker::Number.number(digits: 6) },
                                       website: 'https://this-is-a-test-url.tvs')
  end
  let(:school_2) do
    create(:school, geolocation_trait, name: 'Cambridge Uni',
                                       gias_data: { 'URN' => Faker::Number.number(digits: 6) })
  end
  let(:school_3) do
    create(:school, geolocation_trait, name: 'London LSE',
                                       gias_data: { 'URN' => Faker::Number.number(digits: 6) })
  end

  let(:vacancy) do
    create(:vacancy, :at_multiple_schools, organisation_vacancies_attributes: [
      { organisation: school_1 }, { organisation: school_2 }, { organisation: school_3 }
    ])
  end
  let(:vacancy_presenter) { VacancyPresenter.new(vacancy) }

  before do
    school_group.school_group_memberships.create(school: school_1)
    school_group.school_group_memberships.create(school: school_2)
    school_group.school_group_memberships.create(school: school_3)
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

  context 'when GIAS-obtained website has been overwritten' do
    it 'renders a link to the school website' do
      expect(rendered_component).to include(school_1.website)
      expect(rendered_component).not_to include(school_1.url)
    end
  end

  it 'renders all the GIAS-provided links to the school website' do
    [school_2, school_3].each { |school| expect(rendered_component).to include(school.url) }
  end

  it 'renders the school visits' do
    expect(rendered_component).to include(vacancy.school_visits)
  end

  it 'renders the location heading for multiple schools' do
    expect(rendered_component).to include('School locations')
  end

  context 'when at least one school has a geolocation' do
    it 'shows the map' do
      expect(rendered_component).to include('School locations')
      expect(rendered_component).to include('map')
    end
  end

  context 'when no school has a geolocation' do
    let(:geolocation_trait) { :no_geolocation }

    it 'does not show the map' do
      expect(rendered_component).not_to include('School locations')
      expect(rendered_component).not_to include('map')
    end
  end

  describe '#schools_map_data' do
    let(:school_1_data) do
      JSON.parse(described_class.new(vacancy: vacancy_presenter).schools_map_data).each do |school|
        @school_1_data = school if school['name'] == school_1.name
      end
      @school_1_data
    end

    context 'when the user has provided a website' do
      it 'links to the user-provided website' do
        expect(school_1_data['name_link']).to eq "<a href=\"#{school_1.website}\">#{school_1.name}</a>"
      end
    end

    context 'when the user has NOT provided a website' do
      let(:school_2_data) do
        JSON.parse(described_class.new(vacancy: vacancy_presenter).schools_map_data).each do |school|
          @school_2_data = school if school['name'] == school_2.name
        end
        @school_2_data
      end

      it 'links to the GIAS-provided url' do
        expect(school_2_data['name_link']).to eq "<a href=\"#{school_2.url}\">#{school_2.name}</a>"
      end
    end
  end
end
