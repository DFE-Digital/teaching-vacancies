require 'rails_helper'

RSpec.describe HiringStaff::SchoolsController, type: :controller do
  describe 'index' do
    before { get :index }

    it 'should render the page' do
      expect(response.status).to eql(200)
    end
  end

  describe 'search' do
    before do
      @salisbury_school = create(:school, name: 'Salisbury School')
      create(:school, name: 'Canterbury School')

      get :search, params: { name: 'salisbury' }
    end

    it 'should render the page' do
      expect(response.status).to eql(200)
    end

    it 'should assign the matching school to @schools' do
      expect(assigns(:schools)).to match_array([@salisbury_school])
    end
  end
end
