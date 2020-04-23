require 'rails_helper'

RSpec.describe ApplicationDetailsForm, type: :model do
  subject { ApplicationDetailsForm.new({}) }

  context 'validations' do
    it { should validate_presence_of(:contact_email).with_message('Enter a contact email') }
    it { should validate_presence_of(:publish_on).with_message('Enter the date the role will be listed') }
    it { should validate_presence_of(:expires_on).with_message('Enter the date the application is due') }
    it { should validate_presence_of(:application_link).with_message('Enter a link for jobseekers to apply') }

    describe '#application_link' do
      let(:application_details) { ApplicationDetailsForm.new(application_link: 'not a url') }

      it 'checks for a valid url' do
        expect(application_details.valid?).to be false
        expect(application_details.errors.messages[:application_link][0])
          .to eq('Enter an application link in the correct format, like http://www.school.ac.uk')
      end
    end

    describe '#expiry_time' do
      before(:each) do
        subject.expiry_time_hh = '11'
        subject.expiry_time_mm = '11'
        subject.expiry_time_meridiem = 'am'
      end

      it 'displays error if all fields are blank' do
        subject.expiry_time_hh = nil
        subject.expiry_time_mm = nil
        subject.expiry_time_meridiem = nil
        subject.valid?
        expect(subject.errors.messages[:expiry_time]).to eq(['Enter the time the application is due'])
      end

      validate_expiry_time_hours = [
        { value: nil, errors: ['Enter the time the application is due'] },
        { value: 'not a number', errors: ['Use the correct format for the time the application is due'] },
        { value: '14', errors: ['Use the correct format for the time the application is due'] },
        { value: '0', errors: ['Use the correct format for the time the application is due'] },
      ]

      validate_expiry_time_hours.each do |h|
        it "displays '#{h[:errors][0]}' error when hours field is #{h[:value]}" do
          subject.expiry_time_hh = h[:value]
          subject.valid?
          expect(subject.errors.messages[:expiry_time]).to eq(h[:errors])
        end
      end

      validate_expiry_time_minutes = [
        { value: nil, errors: ['Enter the time the application is due'] },
        { value: 'not a number', errors: ['Use the correct format for the time the application is due'] },
        { value: '-6', errors: ['Use the correct format for the time the application is due'] },
        { value: '66', errors: ['Use the correct format for the time the application is due'] },
      ]

      validate_expiry_time_minutes.each do |m|
        it "displays '#{m[:errors][0]}' error when hours field is #{m[:value]}" do
          subject.expiry_time_mm = m[:value]
          subject.valid?
          expect(subject.errors.messages[:expiry_time]).to eq(m[:errors])
        end
      end

      it 'displays error if am/pm field is blank' do
        subject.expiry_time_meridiem = ''
        subject.valid?
        expect(subject.errors.messages[:expiry_time]).to eq(['Select am or pm'])
      end

      it 'displays only one error message at a time' do
        subject.expiry_time_hh = '14'
        subject.expiry_time_mm = '66'
        subject.expiry_time_meridiem = nil
        subject.valid?
        expect(subject.errors.messages[:expiry_time].count).to eq(1)
      end

      it 'displays wrong format error if minutes and meridiem are invalid' do
        subject.expiry_time_mm = '66'
        subject.expiry_time_meridiem = nil
        subject.valid?
        expect(subject.errors.messages[:expiry_time]).to eq(
          ['Use the correct format for the time the application is due']
        )
      end

      it 'does not display error if all fields are correct' do
        subject.expiry_time_hh = '01'
        subject.expiry_time_mm = '01'
        subject.expiry_time_meridiem = 'am'
        subject.valid?
        expect(subject.errors.messages[:expiry_time]).to be_empty
      end

      it 'can display 24 hours format in 12 hours format AM' do
        application_details = ApplicationDetailsForm.new(expiry_time: Time.parse('6:34').getlocal)
        expect(application_details.expiry_time_hh).to eq('6')
        expect(application_details.expiry_time_mm).to eq('34')
        expect(application_details.expiry_time_meridiem).to eq('am')
        expect(subject.errors.messages[:expiry_time]).to be_empty
      end

      it 'can display 24 hours format in 12 hours format PM' do
        application_details = ApplicationDetailsForm.new(expiry_time: Time.parse('18:00').getlocal)
        expect(application_details.expiry_time_hh).to eq('6')
        expect(application_details.expiry_time_mm).to eq('0')
        expect(application_details.expiry_time_meridiem).to eq('pm')
        expect(subject.errors.messages[:expiry_time]).to be_empty
      end
    end

    describe '#contact_email' do
      let(:application_details) { ApplicationDetailsForm.new(contact_email: 'Some string') }

      it 'checks for a valid email format' do
        expect(application_details.valid?).to be false
        expect(application_details.errors.messages[:contact_email][0])
          .to eq('Enter an email address in the correct format, like name@example.com')
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
        .to eq(I18n.t('activerecord.errors.models.vacancy.attributes.expires_on.before_publish_date'))
      end
    end

    describe '#publish_on' do
      let(:application_details) { ApplicationDetailsForm.new(publish_on: Time.zone.yesterday) }

      it 'the publish date must be present' do
        expect(application_details.valid?).to be false
        expect(application_details.errors.messages[:publish_on][0])
          .to eq(I18n.t('activerecord.errors.models.vacancy.attributes.publish_on.before_today'))
      end
    end
  end

  context 'when expiry time components are given' do
    it 'cannot save expiry time if fields are incomplete' do
      application_details = ApplicationDetailsForm.new(contact_email: 'some@email.com', expiry_time_hh: '9')

      expect(application_details.params_to_save).not_to include(expiry_time_hh: '9')
    end

    it 'can save expiry time if time fields are complete' do
      application_details = ApplicationDetailsForm.new(contact_email: 'some@email.com',
                                                       expires_on: Time.zone.today + 1.week,
                                                       expiry_time_hh: '9',
                                                       expiry_time_mm: '15',
                                                       expiry_time_meridiem: 'am')
      params = application_details.params_to_save
      expect(params.count).to eq(3)
      expect(params[:expiry_time].hour).to eq(9)
      expect(params[:expiry_time].min).to eq(15)
    end
  end

  context 'when all attributes are valid' do
    it 'can correctly be converted to a vacancy' do
      application_details = ApplicationDetailsForm.new(application_link: 'http://an.application.link',
                                                       contact_email: 'some@email.com',
                                                       expires_on: Time.zone.today + 1.week,
                                                       publish_on: Time.zone.today,
                                                       expiry_time_hh: '9', expiry_time_mm: '1',
                                                       expiry_time_meridiem: 'am')

      expect(application_details.valid?).to be true
      expect(application_details.vacancy.contact_email).to eq('some@email.com')
      expect(application_details.vacancy.expires_on).to eq(Time.zone.today + 1.week)
      expect(application_details.vacancy.publish_on).to eq(Time.zone.today)
    end
  end
end
