require 'rails_helper'

RSpec.describe PagesController, type: :controller do
  HighVoltage.page_ids.each do |page|
    context "on GET to /pages/#{page}" do
      before do
        get :show, params: { id: page }
      end

      it { should respond_with(:success) }
      it { should render_template(page) }
    end
  end
end