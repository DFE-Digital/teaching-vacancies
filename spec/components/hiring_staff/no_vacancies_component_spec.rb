require 'rails_helper'

RSpec.describe HiringStaff::NoVacanciesComponent, type: :component do
  let(:organisation) { build(:school) }

  before do
    allow(organisation).to receive_message_chain(:vacancies, :active, :none?).and_return(no_vacancies)
    render_inline(described_class.new(organisation: organisation))
  end

  context 'when organisation has active vacancies' do
    let(:no_vacancies) { false }

    it 'does not render the no vacancies component' do
      expect(rendered_component).to be_blank
    end
  end

  context 'when organisation has no active vacancies' do
    let(:no_vacancies) { true }

    it 'renders the no vacancies component' do
      expect(rendered_component).to include(I18n.t('schools.no_jobs.intro'))
    end
  end
end
