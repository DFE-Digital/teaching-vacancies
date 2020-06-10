require 'rails_helper'

RSpec.describe Schools::VacanciesController, type: :controller do
  describe 'GET /schools/:school_id/vacancies/new' do
    context 'with a valid school id' do
      before do
        @school = create(:school)
        get :new, params: { school_id: @school.id }
      end

      it 'should redirect to the first step of the new vacancy process' do
        expect(response.status).to eql(302)
      end
    end

    context 'without a valid school id' do
      before do
        get :new, params: { school_id: 'XXXX' }
      end

      it 'should be not found' do
        expect(response.status).to eql(404)
      end
    end
  end
end
