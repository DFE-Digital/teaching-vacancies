require 'rails_helper'

RSpec.describe Jobseekers::VacancySummaryComponent, type: :component do
  let(:vacancy_presenter) { VacancyPresenter.new(vacancy) }

  context 'when vacancy job_location is at_one_school' do
    let(:vacancy) { create(:vacancy, :at_one_school) }

    before do
      vacancy.organisation_vacancies.create(organisation: organisation)
      render_inline(described_class.new(vacancy: vacancy_presenter))
    end

    context 'when vacancy parent_organisation is a School' do
      let(:organisation) { create(:school) }

      it 'renders the title' do
        expect(rendered_component).to include(vacancy_presenter.job_title)
      end

      it 'renders the salary' do
        expect(rendered_component).to include(vacancy_presenter.salary)
      end

      it 'renders the address' do
        expect(rendered_component).to include(location(vacancy.parent_organisation))
      end

      it 'renders the school type label' do
        expect(rendered_component).to include(I18n.t('jobs.school_type'))
      end

      it 'renders the school type' do
        expect(rendered_component)
          .to include(organisation_type(organisation: vacancy.parent_organisation, with_age_range: true))
      end

      it 'renders the working pattern' do
        expect(rendered_component).to include(vacancy_presenter.working_patterns)
      end

      context 'when expiry time is nil' do
        let(:vacancy) { create(:vacancy, expiry_time: nil) }

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

    context 'when vacancy parent_organisation is a SchoolGroup' do
      let(:organisation) { create(:school_group) }

      it 'renders the trust type' do
        expect(rendered_component)
          .to include(organisation_type(organisation: vacancy.parent_organisation, with_age_range: true))
      end
    end
  end

  context 'when vacancy job_location is at_multiple_schools' do
    let(:vacancy) { create(:vacancy, :at_multiple_schools) }
    let(:school_type) { create(:school_type, label: 'Academy') }
    let(:school_group) { create(:school_group) }
    let(:school_1) { create(:school, :catholic, school_type: school_type) }
    let(:school_2) { create(:school, :catholic, school_type: school_type) }
    let(:school_3) { create(:school, :catholic, school_type: school_type, minimum_age: 16) }

    before do
      SchoolGroupMembership.find_or_create_by(school_id: school_1.id, school_group_id: school_group.id)
      SchoolGroupMembership.find_or_create_by(school_id: school_2.id, school_group_id: school_group.id)
      SchoolGroupMembership.find_or_create_by(school_id: school_3.id, school_group_id: school_group.id)
      vacancy.organisation_vacancies.create(organisation: school_1)
      vacancy.organisation_vacancies.create(organisation: school_2)
      vacancy.organisation_vacancies.create(organisation: school_3)
      render_inline(described_class.new(vacancy: vacancy_presenter))
    end

    it 'renders the job location' do
      expect(rendered_component)
        .to include(location(vacancy.parent_organisation, job_location: 'at_multiple_schools'))
    end

    it 'renders the unique school types' do
      expect(rendered_component)
        .to include('Academy, Roman Catholic, 11 to 18, Academy, Roman Catholic, 16 to 18')
    end
  end

  context 'when vacancy job_location is central_office' do
    let(:vacancy) { create(:vacancy, :at_central_office) }
    let(:organisation) { create(:school_group) }

    before do
      vacancy.organisation_vacancies.create(organisation: organisation)
      render_inline(described_class.new(vacancy: vacancy_presenter))
    end

    it 'renders the address' do
      assert_includes rendered_component, location(vacancy.parent_organisation)
    end

    it 'renders the trust type label' do
      expect(rendered_component).to include(I18n.t('jobs.trust_type'))
    end

    it 'renders the trust type' do
      expect(rendered_component).to include(organisation_type(organisation: vacancy.parent_organisation))
    end
  end
end
