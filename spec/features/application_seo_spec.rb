require 'rails_helper'
RSpec.feature 'Application meta tags' do
  context 'when visiting the service start page' do
    scenario 'meta tags are present' do
      visit root_path
      expect(page.find('meta[name="keywords"]', visible: false)).to be_present
    end
  end
end
