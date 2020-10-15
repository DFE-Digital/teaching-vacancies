require 'rails_helper'

RSpec.describe HiringStaff::VacanciesComponent, type: :component do
  let(:sort) { VacancySort.new.update(column: 'job_title', order: 'desc') }
  let(:selected_type) { 'published' }
  let(:filters) { {} }
  let(:filters_form) { ManagedOrganisationsForm.new(filters) }

  subject do
    described_class.new(
      organisation: organisation, sort: sort, selected_type: selected_type, filters: filters, filters_form: filters_form,
    )
  end

  context 'when organisation has no active vacancies' do
    let(:organisation) { create(:school, name: 'A school with no jobs') }

    before { render_inline(subject) }

    it 'does not render the vacancies component' do
      expect(rendered_component).to be_blank
    end
  end

  context 'when organisation has active vacancies' do
    let(:organisation) { create(:school, name: 'A school with jobs') }
    let(:vacancy) { create(:vacancy, :published) }

    before { vacancy.organisation_vacancies.create(organisation: organisation) }

    let!(:inline_component) { render_inline(subject) }

    it 'renders the vacancies component' do
      expect(inline_component.css('.govuk-tabs').to_html).not_to be_blank
    end

    it 'renders the number of jobs in the heading' do
      expect(
        inline_component.css('section.govuk-tabs__panel > h2.govuk-heading-m').to_html,
      ).to include('1 published job')
    end

    it 'renders the vacancy job title in the table' do
      expect(inline_component.css('.govuk-table.vacancies').to_html).to include(vacancy.job_title)
    end

    context 'when the organisation is a school' do
      it 'does not render the vacancy readable job location in the table' do
        expect(inline_component.css('.govuk-table.vacancies > tbody > tr > td#vacancy_location').to_html).to be_blank
      end

      it 'does not render the filters sidebar' do
        expect(
          inline_component.css('.new_managed_organisations_form input[type="submit"]'),
        ).to be_blank
      end
    end

    context 'when the organisation is a Trust' do
      let(:organisation) { create(:trust) }
      let!(:vacancy) { create(:vacancy, :published, :at_central_office) }
      let(:filters) { { managed_school_ids: [], managed_organisations: organisation.id } }

      it 'renders the vacancy readable job location in the table' do
        expect(
          inline_component.css('.govuk-table.vacancies > tbody > tr > td#vacancy_location').to_html,
        ).to include(vacancy.readable_job_location)
      end

      it 'renders the filters sidebar' do
        expect(
          inline_component.css('.new_managed_organisations_form input[type="submit"]').attribute('value').value,
        ).to eql(I18n.t('buttons.apply_filters'))
      end
    end
  end

  context 'when filtering results' do
    let(:organisation) { create(:trust) }
    let(:school_oxford) { create(:school, name: 'Oxford') }
    let(:school_cambridge) { create(:school, name: 'Cambridge') }
    let(:vacancy_oxford) do
      create(:vacancy, :published, :at_one_school, readable_job_location: school_oxford.name)
    end
    let(:vacancy_cambridge) do
      create(:vacancy, :published, :at_one_school, readable_job_location: school_cambridge.name)
    end
    let(:filters) { { managed_school_ids: [school_oxford.id], managed_organisations: '' } }

    before do
      vacancy_oxford.organisation_vacancies.create(organisation: school_oxford)
      vacancy_cambridge.organisation_vacancies.create(organisation: organisation)
      vacancy_cambridge.organisation_vacancies.create(organisation: school_cambridge)
    end

    let!(:inline_component) { render_inline(subject) }

    it 'renders the vacancy in Oxford' do
      expect(rendered_component).to include(school_oxford.name)
    end

    it 'does not render the vacancy in Cambridge' do
      expect(rendered_component).not_to include(school_cambridge.name)
    end
  end
end
