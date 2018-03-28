require 'rails_helper'

RSpec.describe ApplicationDetailsForm, type: :model do
  subject { ApplicationDetailsForm.new({}) }

  context 'validations' do
    it { should validate_presence_of(:contact_email) }
    it { should validate_presence_of(:publish_on) }
    it { should validate_presence_of(:expires_on) }

    describe '#application_link' do
      let(:application_details) { ApplicationDetailsForm.new(application_link: 'not a url') }

      it 'checks for a valid url' do
        expect(application_details.valid?).to be false
        expect(application_details.errors.messages[:application_link][0])
          .to eq('is not a valid URL')
      end
    end
    describe '#contact_email' do
      let(:application_details) { ApplicationDetailsForm.new(contact_email: 'Some string') }

      it 'checks for a valid email format' do
        expect(application_details.valid?).to be false
        expect(application_details.errors.messages[:contact_email][0])
          .to eq('is invalid')
      end
    end

    describe '#expires_on' do
      let(:application_details) do
        ApplicationDetailsForm.new(publish_on: Time.zone.tomorrow,
                                   expires_on: Time.zone.today)
      end

      it 'the expiry date must be greater than the publish date' do
        expect(application_details.valid?).to be false
        expect(application_details.errors.messages[:expires_on][0])
          .to eq('can\'t be before the publish date')
      end
    end

    describe '#publish_on' do
      let(:application_details) { ApplicationDetailsForm.new(publish_on: Time.zone.yesterday) }

      it 'the publish date date must be present' do
        expect(application_details.valid?).to be false
        expect(application_details.errors.messages[:publish_on][0])
          .to eq('can\'t be before today')
      end
    end
  end

  context 'when all attributes are valid' do
    it 'can correctly be converted to a vacancy' do
      application_details = ApplicationDetailsForm.new(application_link: 'http://an.application.link',
                                                       contact_email: 'some@email.com',
                                                       expires_on: Time.zone.today + 1.week,
                                                       publish_on: Time.zone.today)

      expect(application_details.valid?).to be true
      expect(application_details.vacancy.contact_email).to eq('some@email.com')
      expect(application_details.vacancy.expires_on).to eq(Time.zone.today + 1.week)
      expect(application_details.vacancy.publish_on).to eq(Time.zone.today)
    end
  end
end
