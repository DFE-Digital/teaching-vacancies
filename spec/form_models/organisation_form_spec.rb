require 'rails_helper'

RSpec.describe OrganisationForm, type: :model do
  let(:subject) { described_class.new(params) }
  let(:params) { { description: description, website: website } }
  let(:description) { 'This is a test description' }
  let(:website) { 'https://www.this-is-a-test-url.tvs' }

  describe '#initialize' do
    it 'assigns attributes' do
      expect(subject.description).to eql(description)
      expect(subject.website).to eql(website)
    end
  end

  describe '#validations' do
    context 'when website is not a valid URL' do
      let(:website) { 'invalid' }

      it 'is invalid' do
        expect(subject.valid?).to be false
        expect(subject.errors.messages[:website].first).to eql(I18n.t('organisation_errors.website.url'))
      end
    end

    context 'when website is a valid URL' do
      it 'is valid' do
        expect(subject.valid?).to be true
      end
    end
  end
end
