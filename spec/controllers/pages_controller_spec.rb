require 'rails_helper'

RSpec.describe PagesController, type: :controller do
  HighVoltage.page_ids.each do |page|
    context "on GET to /pages/#{page}" do
      before do
        get :show, params: { id: page }
      end

      it { should respond_with(:success) }
      it { should render_template(page) }

      it 'should not have a noindex header, unless it is the unauthorised user page or the home page' do
        if page == 'user-not-authorised' || page == 'home'
          expect(response.headers['X-Robots-Tag']).to include('noindex')
        else
          expect(response.headers['X-Robots-Tag']).to_not include('noindex')
        end
      end
    end
  end
end
