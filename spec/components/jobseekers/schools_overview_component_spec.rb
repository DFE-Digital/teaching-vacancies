require 'rails_helper'

RSpec.describe Jobseekers::SchoolsOverviewComponent, type: :component do
  let(:school_group) { create(:school_group) }
  let(:school_1) { create(:school, name: 'Oxford Uni', gias_data: { 'URN' => Faker::Number.number(digits: 6) }) }
  let(:school_2) { create(:school, name: 'Cambridge Uni', gias_data: { 'URN' => Faker::Number.number(digits: 6) }) }
  let(:school_3) { create(:school, name: 'London LSE', gias_data: { 'URN' => Faker::Number.number(digits: 6) }) }
  let(:vacancy) { create(:vacancy, :at_multiple_schools) }
  let(:vacancy_presenter) { VacancyPresenter.new(vacancy) }

  before do
    school_group.school_group_memberships.create(school: school_1)
    school_group.school_group_memberships.create(school: school_2)
    school_group.school_group_memberships.create(school: school_3)
    vacancy.organisation_vacancies.create(organisation: school_1)
    vacancy.organisation_vacancies.create(organisation: school_2)
    vacancy.organisation_vacancies.create(organisation: school_3)
    render_inline(described_class.new(vacancy: vacancy_presenter))
  end

  describe '#render?' do
    context 'when vacancy job_location is central_office' do
      let(:organisation) { create(:school_group) }
      let(:vacancy) { create(:vacancy, :central_office) }

      it 'does not render the component' do
        expect(rendered_component).to be_blank
      end
    end

    context 'when vacancy job_location is at at_one_school' do
      let(:organisation) { create(:school_group) }
      let(:vacancy) { create(:vacancy, :at_one_school) }

      it 'does not render the component' do
        expect(rendered_component).to be_blank
      end
    end

    context 'when vacancy job_location is at_multiple_schools' do
      let(:vacancy) { create(:vacancy, :at_multiple_schools) }

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

  it 'renders all the school links to the school website' do
    [school_1, school_2, school_3].each { |school| expect(rendered_component).to include(school.url) }
  end

  it 'renders the school visits' do
    expect(rendered_component).to include(vacancy.school_visits)
  end
end
