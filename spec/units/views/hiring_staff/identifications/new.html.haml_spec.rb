require 'rails_helper'

RSpec.describe 'hiring_staff/identifications/new.html.haml' do
  context 'FEATURE_SIGN_IN_ALERT is a string "false"' do
    before do
      allow(ENV).to receive(:[]).with('FEATURE_SIGN_IN_ALERT').and_return('false')
      render
    end

    it 'does not show the sign in warning' do
      expect(render).not_to match(/#{I18n.t('hiring_staff.identifications.new.you_might_have_problems_signing_in')}/)
    end
  end

  context 'FEATURE_SIGN_IN_ALERT is a boolean false' do
    before do
      allow(ENV).to receive(:[]).with('FEATURE_SIGN_IN_ALERT').and_return(false)
      render
    end

    it 'does not show the sign in warning' do
      expect(render).not_to match(/#{I18n.t('hiring_staff.identifications.new.you_might_have_problems_signing_in')}/)
    end
  end

  context 'FEATURE_SIGN_IN_ALERT is as string "true"' do
    before do
      allow(ENV).to receive(:[]).with('FEATURE_SIGN_IN_ALERT').and_return('true')
      render
    end

    it 'shows the sign in warning' do
      expect(render).to match(/#{I18n.t('hiring_staff.identifications.new.you_might_have_problems_signing_in')}/)
    end
  end

  context 'FEATURE_SIGN_IN_ALERT is as boolean true' do
    before do
      allow(ENV).to receive(:[]).with('FEATURE_SIGN_IN_ALERT').and_return(true)
      render
    end

    it 'shows the sign in warning' do
      expect(render).to match(/#{I18n.t('hiring_staff.identifications.new.you_might_have_problems_signing_in')}/)
    end
  end
end
