require 'rails_helper'
require 'feature_flag'

RSpec.describe FeatureFlag do
  subject { described_class.new('email_alerts') }

  context 'when the flag is set to true' do
    before { stub_const('FEATURE_EMAIL_ALERTS', 'true') }

    it { expect(subject.enabled?).to eq(true) }
  end

  context 'when the flag is set to false' do
    before { stub_const('FEATURE_EMAIL_ALERTS', 'false') }

    it { expect(subject.enabled?).to eq(false) }
  end

  context 'when the flag is not set' do
    before { stub_const('FEATURE_EMAIL_ALERTS', nil) }

    it { expect(subject.enabled?).to eq(false) }
  end
end