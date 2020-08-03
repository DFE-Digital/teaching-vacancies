require 'rails_helper'

RSpec.describe HiringStaff::VacanciesComponent, type: :component do
  let(:sort) { VacancySort.new.update(column: 'job_title', order: 'desc') }
  let(:selected_type) { 'published' }

  context 'when organisation has no active vacancies' do
    let(:organisation) { create(:school, name: 'A school with no jobs') }

    before { render_inline(described_class.new(organisation: organisation, sort: sort, selected_type: selected_type)) }

    it 'does not render the vacancies component' do
      expect(rendered_component).to be_blank
    end
  end

  context 'when organisation has active vacancies' do
    let(:organisation) { create(:school, name: 'A school with jobs') }
    let!(:vacancy) { create(:vacancy, :published, school: organisation) }
    let!(:component) do
      described_class.new(organisation: organisation, sort: sort, selected_type: selected_type)
    end
    let!(:inline_component) { render_inline(component) }

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

  # Unit test for now, until we use the method in a feature
  describe '#job_location_options' do
    let!(:school_group) { create(:school_group) }
    let!(:school_1) { create(:school, name: 'A school with two jobs', urn: 123) }
    let!(:school_2) { create(:school, name: 'A school with no jobs', urn: 321) }

    let(:component) do
      described_class.new(organisation: school_group, sort: sort, selected_type: selected_type)
    end

    before do
      create(:vacancy, :published, :with_school_group_at_school,
        school: school_1,
        school_group: school_group)
      create(:vacancy, :published, :with_school_group_at_school,
        school: school_1,
        school_group: school_group)
      create(:vacancy, :published, :with_school_group, school_group: school_group)
      school_group.schools = [school_1, school_2]
      school_group.save
    end

    it 'lists the school names, trust head office, and the number of published jobs at each' do
      expect(component.instance_variable_get(:@job_location_options)).to eq([
          ['Trust head office (1)', 'school_group'],
          ['A school with no jobs (0)', '321'],
          ['A school with two jobs (2)', '123']
      ])
    end
  end
end
