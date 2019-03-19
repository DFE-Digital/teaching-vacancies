require 'rails_helper'

RSpec.describe AlertMailer, type: :mailer do
  include DateHelper
  let(:body) { mail.body.raw_source }
  let(:subscription) do
    create(:daily_subscription, email: 'an@email.com',
                                reference: 'a-reference',
                                search_criteria: {
                                  keyword: 'English',
                                  minimum_salary: 20000,
                                  maximum_salary: 40000,
                                  newly_qualified_teacher: 'true'
                                }.to_json)
  end

  describe 'daily_alert' do
    before(:each) do
      stub_const('NOTIFY_SUBSCRIPTION_DAILY_TEMPLATE', '')
    end

    let(:mail) { described_class.daily_alert(subscription.id, vacancies.pluck(:id)) }
    let(:vacancies) { create_list(:vacancy, 1, :published) }
    let(:campaign_params) { { source: 'subscription', medium: 'email', campaign: 'daily_alert' } }

    context 'with a single vacancy' do
      let(:vacancy_presenter) { VacancyPresenter.new(vacancies.first) }

      it 'shows a vacancy' do
        expect(mail.subject).to eq(I18n.t('alerts.email.daily.subject.one'))
        expect(mail.to).to eq([subscription.email])

        expect(body).to match(/# #{I18n.t('app.title')}/)
        expect(body).to match(/# #{I18n.t('alerts.email.daily.summary.one')}/)
        expect(body).to match(/---/)
        expect(body).to match(/#{Regexp.escape(vacancy_presenter.share_url(campaign_params))}/)
        expect(body).to match(/#{vacancy_presenter.location}/)
        expect(body).to match(/Salary: #{vacancy_presenter.salary_range}/)

        expect(body).to match(/#{vacancy_presenter.working_pattern}/)

        expect(body).to match(/#{format_date(vacancy_presenter.expires_on)}/)
      end
    end

    context 'with multiple vacancies' do
      let(:vacancies) { create_list(:vacancy, 2, :published) }
      let(:first_vacancy_presenter) { VacancyPresenter.new(vacancies.first) }
      let(:second_vacancy_presenter) { VacancyPresenter.new(vacancies.last) }

      it 'shows vacancies' do
        expect(mail.subject).to eq(I18n.t('alerts.email.daily.subject.other', count: vacancies.count))
        expect(mail.to).to eq([subscription.email])

        expect(body).to match(/\[#{first_vacancy_presenter.job_title}\]/)
        expect(body).to match(/#{Regexp.escape(first_vacancy_presenter.share_url(campaign_params))}/)
        expect(body).to match(/#{first_vacancy_presenter.location}/)
        expect(body).to match(/Salary: #{first_vacancy_presenter.salary_range}/)
        expect(body).to match(/#{first_vacancy_presenter.working_pattern}/)
        expect(body).to match(/#{format_date(first_vacancy_presenter.expires_on)}/)

        expect(body).to match(/\[#{second_vacancy_presenter.job_title}\]/)
        expect(body).to match(/#{Regexp.escape(second_vacancy_presenter.share_url(campaign_params))}/)
        expect(body).to match(/#{second_vacancy_presenter.location}/)
        expect(body).to match(/Salary: #{second_vacancy_presenter.salary_range}/)
        expect(body).to match(/#{second_vacancy_presenter.working_pattern}/)
        expect(body).to match(/#{format_date(second_vacancy_presenter.expires_on)}/)
      end
    end
  end
end
