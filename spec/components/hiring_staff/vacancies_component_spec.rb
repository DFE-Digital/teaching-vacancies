require 'rails_helper'

RSpec.describe HiringStaff::VacanciesComponent, type: :component do
  let(:sort) { VacancySort.new.update(column: 'job_title', order: 'desc') }
  let(:selected_type) { 'published' }
  let(:filters) { {} }

  subject do
    described_class.new(organisation: organisation, sort: sort, selected_type: selected_type, filters: filters)
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
    let!(:vacancy) { create(:vacancy, :published, school: organisation) }
    let!(:inline_component) { render_inline(subject) }

    it 'renders the vacancies component' do
      expect(inline_component.css('.govuk-tabs').to_html).not_to be_blank
    end

    it 'renders the number of jobs in the heading' do
      expect(
        inline_component.css('section.govuk-tabs__panel > h2.govuk-heading-m').to_html
      ).to include('1 Published jobs')
    end

    it 'renders the vacancy job title in the table' do
      expect(inline_component.css('.govuk-table.vacancies').to_html).to include(vacancy.job_title)
    end

    context 'when the organisation is a school' do
      it 'does not render the vacancy readable job location in the table' do
        expect(inline_component.css('.govuk-table.vacancies > tbody > tr > td#vacancy_location').to_html).to be_blank
      end
    end

    context 'when the organisation is a school group' do
      let(:organisation) { create(:school_group) }
      let!(:vacancy) { create(:vacancy, :published, :with_school_group, school_group: organisation) }

      it 'renders the vacancy readable job location in the table' do
        expect(
          inline_component.css('.govuk-table.vacancies > tbody > tr > td#vacancy_location').to_html
        ).to include(vacancy.readable_job_location)
      end
    end
  end

  context 'when filtering results' do
    let(:organisation) { create(:school_group) }
    let!(:school_oxford) { create(:school, name: 'Oxford') }
    let!(:school_cambridge) { create(:school, name: 'Cambridge') }
    let!(:vacancy_oxford) { create(:vacancy, :published, :with_school_group_at_school,
      school_group: organisation, school: school_oxford)
    }
    let!(:vacancy_cambridge) { create(:vacancy, :published, :with_school_group_at_school,
      school_group: organisation, school: school_cambridge)
    }

    let!(:inline_component) { render_inline(subject) }

    let(:filters) { { managed_school_ids: [school_oxford.id], managed_organisations: '' } }

    it 'renders the vacancy in Oxford' do
      expect(rendered_component).to include(school_oxford.name)
    end

    it 'does not render the vacancy in Cambridge' do
      expect(rendered_component).not_to include(school_cambridge.name)
    end
  end
end
