require 'rails_helper'

RSpec.describe 'hiring_staff/documents/edit' do
  before do
    render
  end

  it 'renders something' do
    expect(rendered).not_to be_blank
  end

  it 'shows that we are on step two of the process' do
    expect(rendered).to match(/step 2 of 3/i)
  end

  it 'shows "Upload a file"' do
    expect(rendered).to match('Upload a file')
  end
end
