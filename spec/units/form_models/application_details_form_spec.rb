require 'rails_helper'

RSpec.describe ApplicationDetailsForm, type: :model do
  subject { ApplicationDetailsForm.new({}) }

  context 'validations' do
    it { should validate_presence_of(:contact_email).with_message('Enter a contact email') }

    describe '#application_link' do
      let(:application_details) { ApplicationDetailsForm.new(application_link: 'not a url') }

      it 'checks for a valid url' do
        expect(application_details.valid?).to be false
        expect(application_details.errors.messages[:application_link][0])
          .to eq(I18n.t('application_details_errors.application_link.url'))
      end
    end

    describe '#contact_email' do
      let(:application_details) { ApplicationDetailsForm.new(contact_email: 'Some string') }

      it 'checks for a valid email format' do
        expect(application_details.valid?).to be false
        expect(application_details.errors.messages[:contact_email][0])
          .to eq(I18n.t('application_details_errors.contact_email.invalid'))
      end
    end
  end

  context 'when all attributes are valid' do
    it 'can correctly be converted to a vacancy' do
      application_details = ApplicationDetailsForm.new(state: 'create',
                                                       application_link: 'http://an.application.link',
                                                       contact_email: 'some@email.com',
                                                       school_visits: 'How you can visit the school',
                                                       how_to_apply: 'How you can apply for the job')

      expect(application_details.valid?).to be true
      expect(application_details.vacancy.contact_email).to eql('some@email.com')
      expect(application_details.vacancy.application_link).to eql('http://an.application.link')
      expect(application_details.vacancy.school_visits).to eql('How you can visit the school')
      expect(application_details.vacancy.how_to_apply).to eql('How you can apply for the job')
    end
  end
end
