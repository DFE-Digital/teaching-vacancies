require 'rails_helper'

RSpec.describe Jobseekers::SchoolOverviewComponent, type: :component do
  let(:organisation) { create(:school) }
  let(:vacancy) { create(:vacancy, :at_one_school) }
  let(:vacancy_presenter) { VacancyPresenter.new(vacancy) }

  before do
    vacancy.organisation_vacancies.create(organisation: organisation)
    render_inline(described_class.new(vacancy: vacancy_presenter))
  end

  describe '#render?' do
    context 'when vacancy is at a trust head office' do
      let(:organisation) { create(:school_group) }
      let(:vacancy) { create(:vacancy, :at_central_office) }

      it 'does not render the component' do
        expect(rendered_component).to be_blank
      end
    end

    context 'when vacancy is at a single school in a trust' do
      let(:vacancy) { create(:vacancy, :at_one_school) }

      it 'renders the component' do
        expect(rendered_component).not_to be_blank
      end
    end
  end

  context 'rendering the school type' do
    it 'renders the school type' do
      expect(rendered_component).to include(organisation_type(organisation: vacancy.parent_organisation,
        with_age_range: false))
    end

    it 'does not render the age range as part of the school type' do
      expect(rendered_component).not_to include(organisation_type(organisation: vacancy.parent_organisation,
        with_age_range: true))
    end
  end

  it 'renders the education phase' do
    expect(rendered_component).to include(school_phase(vacancy.parent_organisation))
  end

  context 'when the number of pupils is present' do
    it 'renders the school size as the number of pupils' do
      expect(rendered_component).to include(school_size(vacancy.parent_organisation))
    end
  end

  context 'when the number of pupils is not present' do
    context 'when the school capacity is present' do
      let(:school) { create(:school, gias_data: { 'NumberOfPupils' => nil, 'SchoolCapacity' => 1000 }) }

      it 'renders the school capacity as the school size' do
        expect(rendered_component).to include(school_size(vacancy.parent_organisation))
      end
    end

    context 'when the school capacity is not present' do
      let(:school) { create(:school, gias_data: { 'NumberOfPupils' => nil, 'SchoolCapacity' => nil }) }

      it 'renders the school no information translation' do
        expect(rendered_component).to include(school_size(vacancy.parent_organisation))
      end
    end
  end

  context 'when an ofsted report is present' do
    let(:organisation) { create(:school, gias_data: { 'URN' => Faker::Number.number(digits: 6) }) }

    it 'renders the osted report' do
      expect(rendered_component).to include(ofsted_report(vacancy.parent_organisation))
    end
  end

  context 'when an ofsted report is not present' do
    it 'does not render the osted report' do
      expect(rendered_component).to include(I18n.t('schools.no_information'))
    end
  end

  it 'renders a link to the school website' do
    expect(rendered_component).to include(vacancy.parent_organisation.url)
  end

  it 'renders the contact email' do
    expect(rendered_component).to include(vacancy.contact_email)
  end

  it 'renders about school or organisation description' do
    expect(rendered_component).to include(vacancy_or_organisation_description(vacancy))
  end

  it 'renders school visits' do
    expect(rendered_component).to include(vacancy.school_visits)
  end

  it 'renders the head office location' do
    expect(rendered_component).to include(full_address(vacancy.parent_organisation))
  end
end
