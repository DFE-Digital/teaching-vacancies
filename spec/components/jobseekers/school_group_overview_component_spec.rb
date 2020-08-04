require 'rails_helper'

RSpec.describe Jobseekers::SchoolGroupOverviewComponent, type: :component do
  let(:school_group) { create(:school_group) }
  let(:vacancy) { create(:vacancy, school_group: school_group) }
  let(:vacancy_presenter) { VacancyPresenter.new(vacancy) }

  before { render_inline(described_class.new(vacancy: vacancy_presenter)) }

  it 'renders the trust type' do
    expect(rendered_component).to include(organisation_type(vacancy.school_group))
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
