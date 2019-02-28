require 'rails_helper'

RSpec.describe AlertMailer, type: :mailer do
  let(:body_lines) { mail.body.raw_source.lines }
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

        expect(body_lines[0]).to match(/# #{I18n.t('app.title')}/)
        expect(body_lines[1]).to match(/# #{I18n.t('alerts.email.daily.summary.one')}/)
        expect(body_lines[3]).to match(/---/)
        expect(body_lines[5]).to eql(
          "[#{vacancy_presenter.job_title}](#{vacancy_presenter.share_url(campaign_params)})\r\n"
        )
        expect(body_lines[6]).to match(/#{vacancy_presenter.school_name}/)
        expect(body_lines[7]).to match(/Salary: #{vacancy_presenter.salary_range}/)
      end
    end

    context 'with multiple vacancies' do
      let(:vacancies) { create_list(:vacancy, 2, :published) }
      let(:first_vacancy_presenter) { VacancyPresenter.new(vacancies.first) }
      let(:second_vacancy_presenter) { VacancyPresenter.new(vacancies.last) }

      it 'shows vacancies' do
        expect(mail.subject).to eq(I18n.t('alerts.email.daily.subject.other', count: vacancies.count))
        expect(mail.to).to eq([subscription.email])

        expect(body_lines[5]).to match(/\[#{first_vacancy_presenter.job_title}\]/)
        expect(body_lines[5]).to eql(
          "[#{first_vacancy_presenter.job_title}](#{first_vacancy_presenter.share_url(campaign_params)})\r\n"
        )
        expect(body_lines[6]).to match(/#{first_vacancy_presenter.school_name}/)
        expect(body_lines[7]).to match(/Salary: #{first_vacancy_presenter.salary_range}/)

        expect(body_lines[9]).to match(/\[#{second_vacancy_presenter.job_title}\]/)
        expect(body_lines[9]).to eql(
          "[#{second_vacancy_presenter.job_title}](#{second_vacancy_presenter.share_url(campaign_params)})\r\n"
        )
        expect(body_lines[10]).to match(/#{second_vacancy_presenter.school_name}/)
        expect(body_lines[11]).to match(/Salary: #{second_vacancy_presenter.salary_range}/)
      end
    end
  end
end
