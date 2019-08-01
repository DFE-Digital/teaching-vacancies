require 'rails_helper'

RSpec.describe FeedbackPromptMailer, type: :mailer do
  include DateHelper

  let(:body) { mail.body.raw_source }

  describe 'prompt_for_feedback' do
    before(:each) do
      stub_const('NOTIFY_PROMPT_FEEDBACK_FOR_EXPIRED_VACANCIES', '')
    end
    let(:email_address) { 'dummy@dum.com' }
    let(:mail) { described_class.prompt_for_feedback(email_address, vacancies) }
    let(:vacancies) { create_list(:vacancy, 2, :published) }

    context 'with two vacancies' do
      it 'shows both vacancies' do
        expect(mail.subject).to eq('Teaching Vacancies needs your feedback on expired job listings')
        expect(mail.to).to eq([email_address])

        expect(body).to match(/Dear vacancy publisher/)

        expect(body).to match(/\* #{vacancies.first.job_title}/)
        expect(body).to match(/\* #{vacancies.second.job_title}/)
      end
    end
  end
end
