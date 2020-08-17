require 'rails_helper'

RSpec.describe Jobseekers::SchoolGroupOverviewComponent, type: :component do
  let(:school_group) { create(:school_group) }
  let(:vacancy) { create(:vacancy, :with_school_group, school_group: school_group) }
  let(:vacancy_presenter) { VacancyPresenter.new(vacancy) }

  before { render_inline(described_class.new(vacancy: vacancy_presenter)) }

  describe '#render?' do
    let(:school) { create(:school) }

    context 'when vacancy is at a school without a trust' do
      let(:vacancy) { create(:vacancy, school: school) }

      it 'does not render the component' do
        expect(rendered_component).to be_blank
      end
    end

    context 'when vacancy is at a single school in a trust' do
      let(:vacancy) { create(:vacancy, :with_school_group_at_school, school_group: school_group) }

      it 'does not render the component' do
        expect(rendered_component).to be_blank
      end
    end

    context 'when vacancy is at a trust head office' do
      it 'renders the component' do
        expect(rendered_component).not_to be_blank
      end
    end
  end

  it 'renders the trust type' do
    expect(rendered_component).to include(organisation_type(organisation: vacancy.school_group))
  end

  it 'renders the trust email' do
    expect(rendered_component).to include(vacancy.contact_email)
  end

  it 'renders about school or organisation description' do
    expect(rendered_component).to include(vacancy_or_organisation_description(vacancy))
  end

  # TODO: school_visits needs to be changed to organisation_visits
  it 'renders school visits' do
    expect(rendered_component).to include(vacancy.school_visits)
  end

  it 'renders the head office location' do
    expect(rendered_component).to include(full_address(vacancy.school_group))
  end
end
