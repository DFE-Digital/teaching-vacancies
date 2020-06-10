require 'rails_helper'

RSpec.describe InterestsController, type: :controller do
  describe 'GET #new' do
    it 'redirects to the vacancy application link' do
      vacancy = create(:vacancy, application_link: 'http://foo.com')

      get :new, params: { job_id: vacancy.id }

      expect(request).to redirect_to('http://foo.com')
    end

    context 'when the old vacancy url is used' do
      it 'redirects to the vacancy application link' do
        vacancy = create(:vacancy, application_link: 'http://bar.com')

        get :new, params: { vacancy_id: vacancy.id }

        expect(request).to redirect_to('http://bar.com')
      end
    end
  end
end
