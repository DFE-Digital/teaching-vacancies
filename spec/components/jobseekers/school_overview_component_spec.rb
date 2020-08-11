require 'rails_helper'

RSpec.describe Jobseekers::SchoolOverviewComponent, type: :component do
  let(:school) { create(:school) }
  let(:vacancy) { create(:vacancy, school: school) }
  let(:vacancy_presenter) { VacancyPresenter.new(vacancy) }

  before { render_inline(described_class.new(vacancy: vacancy_presenter)) }

  describe '#render?' do
    let(:school_group) { create(:school_group) }

    context 'when vacancy is at a trust head office' do
      let(:vacancy) { create(:vacancy, :with_school_group, school_group: school_group) }

      it 'does not render the component' do
        expect(rendered_component).to be_blank
      end
    end

    context 'when vacancy is at a single school in a trust' do
      let(:vacancy) { create(:vacancy, :with_school_group_at_school, school_group: school_group) }

      it 'renders the component' do
        expect(rendered_component).not_to be_blank
      end
    end
  end

  it 'renders the school type' do
    expect(rendered_component).to include(organisation_type(organisation: vacancy.school))
  end

  it 'renders the education phase' do
    expect(rendered_component).to include(vacancy.school.phase.titleize)
  end

  context 'when the number of pupils is present' do
    it 'renders the school size as the number of pupils' do
      expect(rendered_component).to include(school_size(vacancy.school))
    end
  end

  context 'when the number of pupils is not present' do
    context 'when the school capacity is present' do
      let(:school) { create(:school, gias_data: { 'NumberOfPupils' => nil, 'SchoolCapacity' => 1000 }) }

      it 'renders the school capacity as the school size' do
        expect(rendered_component).to include(school_size(vacancy.school))
      end
    end

    context 'when the school capacity is not present' do
      let(:school) { create(:school, gias_data: { 'NumberOfPupils' => nil, 'SchoolCapacity' => nil }) }

      it 'renders the school no information translation' do
        expect(rendered_component).to include(school_size(vacancy.school))
      end
    end
  end

  context 'when an ofsted report is present' do
    let(:school) { create(:school, gias_data: { 'URN' => Faker::Number.number(digits: 6) }) }

    it 'renders the osted report' do
      expect(rendered_component).to include(ofsted_report(vacancy.school))
    end
  end

  context 'when an ofsted report is not present' do
    it 'does not render the osted report' do
      expect(rendered_component).to include(I18n.t('schools.no_information'))
    end
  end

  it 'renders a link to the school website' do
    expect(rendered_component).to include(vacancy.school.url)
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
    expect(rendered_component).to include(full_address(vacancy.school))
  end
end
