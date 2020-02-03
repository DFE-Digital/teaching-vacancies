require 'rails_helper'

RSpec.describe 'hiring_staff/documents/new' do
  before do
    render
  end

  it 'renders something' do
    expect(rendered).not_to be_blank
  end

  it 'shows that we are on step two of the process' do
    expect(rendered).to match(/step 2 of 3/i)
  end

  it 'shows the yes/no control' do
    expect(rendered).to match('Yes')
    expect(rendered).to match('No')
  end
end
