require 'rails_helper'

RSpec.describe Jobseekers::SearchResults::JobAlertsLinkComponent, type: :component do
  subject { described_class.new(vacancies_search: vacancies_search) }

  let(:vacancies_search) { instance_double(Algolia::VacancySearchBuilder) }
  let(:active_hash) { { keyword: 'maths' } }

  before do
    allow(vacancies_search).to receive(:only_active_to_hash).and_return(active_hash)
    allow(vacancies_search).to receive(:any?).and_return(search_params_present)
    allow(EmailAlertsFeature).to receive(:enabled?).and_return(email_alerts_enabled)
    allow(ReadOnlyFeature).to receive(:enabled?).and_return(read_only_enabled)
  end

  let!(:inline_component) { render_inline(subject) }

  context 'when a search is carried out' do
    let(:search_params_present) { true }

    context 'when EmailAlertsFeature is enabled' do
      let(:email_alerts_enabled) { true }

      context 'when ReadOnlyFeature is disabled' do
        let(:read_only_enabled) { false }

        it 'renders the job alerts link' do
          expect(inline_component.css(
            'a.govuk-link#job-alert-link[href='\
            "'#{Rails.application.routes.url_helpers.new_subscription_path(search_criteria: active_hash)}']"
            ).to_html
          ).to include(I18n.t('subscriptions.link.text'))
        end
      end

      context 'when ReadOnlyFeature is enabled' do
        let(:read_only_enabled) { true }

        it 'does not render the job alerts link' do
          expect(rendered_component).to be_blank
        end
      end
    end

    context 'when EmailAlertsFeature is disabled' do
      let(:email_alerts_enabled) { false }
      let(:read_only_enabled) { true }

      it 'does not render the job alerts link' do
        expect(rendered_component).to be_blank
      end
    end
  end

  context 'when a search is not carried out' do
    let(:search_params_present) { false }
    let(:email_alerts_enabled) { false }
    let(:read_only_enabled) { true }

    it 'does not render the job alerts link' do
      expect(rendered_component).to be_blank
    end
  end
end
