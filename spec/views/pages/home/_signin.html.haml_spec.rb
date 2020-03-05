require 'rails_helper'

RSpec.describe 'pages/home/_signin.html.haml' do
  context 'FEATURE_SIGN_IN_ALERT is a string "false"' do
    before do
      allow(ENV).to receive(:[]).with('FEATURE_SIGN_IN_ALERT').and_return('false')
      render
    end

    it 'displays the regular signin workflow' do
      expect(render).to have_css('.identifications')
    end
  end

  context 'FEATURE_SIGN_IN_ALERT is a boolean false' do
    before do
      allow(ENV).to receive(:[]).with('FEATURE_SIGN_IN_ALERT').and_return(false)
      render
    end

    it 'displays the regular signin workflow' do
      expect(render).to have_css('.identifications')
    end
  end

  context 'FEATURE_SIGN_IN_ALERT is as string "true"' do
    before do
      allow(ENV).to receive(:[]).with('FEATURE_SIGN_IN_ALERT').and_return('true')
      render
    end

    it 'displays the regular signin workflow' do
      expect(render).to have_css('.identifications-button')
    end
  end

  context 'FEATURE_SIGN_IN_ALERT is as boolean true' do
    before do
      allow(ENV).to receive(:[]).with('FEATURE_SIGN_IN_ALERT').and_return(true)
      render
    end

    it 'displays the regular signin workflow' do
      expect(render).to have_css('.identifications-button')
    end
  end
end
