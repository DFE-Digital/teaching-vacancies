require 'rails_helper'

RSpec.describe Jobseekers::VacancySummaryComponent, type: :component do
  let(:vacancy_presenter) { VacancyPresenter.new(vacancy) }

  before { render_inline(described_class.new(vacancy: vacancy_presenter)) }

  context 'when vacancy is at a school that is not in a trust' do
    let(:school) { create(:school) }
    let(:vacancy) { create(:vacancy, school: school) }

    it 'renders the title' do
      expect(rendered_component).to include(vacancy_presenter.job_title)
    end

    it 'renders the salary' do
      expect(rendered_component).to include(vacancy_presenter.salary)
    end

    it 'renders the address' do
      expect(rendered_component).to include(location(vacancy.school))
    end

    it 'renders the school type label' do
      expect(rendered_component).to include(I18n.t('jobs.school_type'))
    end

    it 'renders the school type' do
      expect(rendered_component).to include(organisation_type(organisation: vacancy.school, with_age_range: true))
    end

    it 'renders the working pattern' do
      expect(rendered_component).to include(vacancy_presenter.working_patterns)
    end

    context 'when expiry time is nil' do
      let(:vacancy) { create(:vacancy, school: school, expiry_time: nil) }

      it 'renders the date it expires on but not the time' do
        expect(rendered_component).to include(format_date(vacancy.expires_on))
      end
    end

    context 'when expiry time is not nil' do
      it 'renders the date and time it expires at' do
        expect(rendered_component).to include(expiry_date_and_time(vacancy))
      end
    end
  end

  context 'when vacancy is at a single school in a trust' do
    let(:vacancy) { create(:vacancy, :with_school_group_at_school) }

    it 'renders the trust type' do
      expect(rendered_component)
        .to include(organisation_type(organisation: vacancy.school, with_age_range: true))
    end
  end

  context 'when vacancy is at central office in a trust' do
    let(:vacancy) { create(:vacancy, :with_school_group) }

    it 'renders the address' do
      assert_includes rendered_component, location(vacancy.school_group)
    end

    it 'renders the trust type label' do
      expect(rendered_component).to include(I18n.t('jobs.trust_type'))
    end

    it 'renders the trust type' do
      expect(rendered_component).to include(organisation_type(organisation: vacancy.school_group))
    end
  end
end
